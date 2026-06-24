import 'dart:async';
import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genui/genui.dart' hide TextPart;
import 'package:get/get.dart';

import '../catalog/klinika_catalog.dart';

class IntakeController extends GetxController {
  late SurfaceController surfaceController;
  late A2uiTransportAdapter transport;
  late Conversation conversation;
  StreamSubscription<ConversationEvent>? _conversationSubscription;

  final textController = TextEditingController();
  final chatScrollController = ScrollController();
  final surfaceIds = <String>[].obs;
  final lockedSurfaceIds = <String>[].obs;
  final assistantMessages = <String>[].obs;
  final isLoading = false.obs;
  final hasStarted = false.obs;
  final shouldHideMainInput = false.obs;
  final errorMessage = RxnString();
  final _history = <Content>[];
  final _surfaceHasInteractiveInput = <String, bool>{};

  GenerativeModel? _model;

  static const _clinicalPrompt = '''
You are a smart, empathetic patient intake assistant for a health facility in Yaounde, Cameroon.
Patients may speak French, English, Camfranglais, or a mix. Always respond in the same language the patient uses.
Your job is to guide adaptive patient intake. Use GenUI widgets when interaction helps, and use a clear structured text response when the patient no longer needs another field.

CLINICAL UX RULES:
1. When a patient describes symptoms, always start by generating a TriageBanner with:
   - severity: "urgent" | "moderate" | "routine"
   - message: a short explanation in the patient's language

2. Then generate a DepartmentSelector with the most appropriate department.

3. Then generate a SymptomChipGroup with related symptoms they might confirm.

4. Then generate a form with relevant follow-up fields using ClinicalTextInput, ChoicePicker, PainScale, DurationSelector, YesNoCheck, or other core widgets when you need more information.
   Only ask what is clinically relevant to what the patient described.
   Do not ask for information that is already obvious from their description.

5. Every generated form MUST include an obvious submit/continue Button after input fields.
   The button action MUST be an event named "continue_intake".
   The event context MUST include the values collected in that surface using {"path": "..."} bindings.

6. Keep the conversation human. Do not be robotic.

7. Never generate the same form twice. Each response should adapt to what you now know.

8. Create a new unique surfaceId for every assistant response. Do not reuse earlier surface IDs.

9. Do NOT generate interactive UI on every turn. If the next best step is advice, summary, reassurance, or a final intake handoff, return a structured plain-text response instead.

10. After the user has answered enough follow-up questions, finalize warmly. Summarize what you understood, name the recommended service/urgency, give practical next steps, and do not ask for more input.

CRITICAL A2UI RULES:
- These A2UI rules apply ONLY when you decide to render UI.
- If you render UI, output A2UI JSON messages wrapped in ```json code fences.
- If you render UI, every A2UI JSON object MUST include exactly: "version": "v0.9".
- NEVER output generic JSON like {"type":"Form","fields":[...]}.
- To render a UI, output TWO A2UI messages in this order:
  1. createSurface
  2. updateComponents
- The updateComponents message MUST include a component with "id": "root".
- Use only known component names from the catalog. The field is "component", not "type".
- For choice fields, use ChoicePicker from the basic catalog, not Select.
- For numeric symptom intensity use PainScale.
- For symptom duration use DurationSelector.
- For quick binary clinical checks use YesNoCheck.
- For free-text answers, prefer ClinicalTextInput because it includes a built-in submit button.
- TextField values should use explicit data paths like {"path": "/duration_notes"}.
- TextFields can use onSubmittedAction, but they still need a visible Button after the fields.

PLAIN-TEXT FINAL RESPONSE RULES:
- Use plain text or Markdown-style bullets, not JSON.
- Keep it friendly, concise, and actionable.
- Mention that this is intake guidance, not a diagnosis.
- For urgent symptoms, clearly recommend urgent care/emergency evaluation.
- Do not end with another question once you are finalizing.

EXAMPLE SHAPE:
```json
{
  "version": "v0.9",
  "createSurface": {
    "surfaceId": "triage_1",
    "catalogId": "https://a2ui.org/specification/v0_9/basic_catalog.json",
    "sendDataModel": true
  }
}
```

```json
{
  "version": "v0.9",
  "updateComponents": {
    "surfaceId": "triage_1",
    "components": [
      {
        "id": "root",
        "component": "Column",
        "children": ["triage", "department", "symptoms", "question", "submit"]
      },
      {
        "id": "triage",
        "component": "TriageBanner",
        "severity": "moderate",
        "message": "On doit verifier la fievre et le rash."
      },
      {
        "id": "department",
        "component": "DepartmentSelector",
        "department": "Pediatrie",
        "reason": "Rash and fever in a child need pediatric triage."
      },
      {
        "id": "symptoms",
        "component": "SymptomChipGroup",
        "label": "Symptomes associes",
        "chips": ["Fievre", "Rash", "Vomissements"]
      },
      {
        "id": "question",
        "component": "ClinicalTextInput",
        "label": "Depuis quand exactement?",
        "value": {"path": "/duration_notes"}
      },
      {
        "id": "submit_label",
        "component": "Text",
        "text": "Continuer"
      },
      {
        "id": "submit",
        "component": "Button",
        "variant": "primary",
        "child": "submit_label",
        "action": {
          "event": {
            "name": "continue_intake",
            "context": {
              "duration_notes": {"path": "/duration_notes"}
            }
          }
        }
      }
    ]
  }
}
```
''';

  @override
  void onInit() {
    super.onInit();
    _initGenUI();
  }

  GenerativeModel _ensureFirebaseAI() {
    final catalog = buildKlinikaCatalog();
    final systemPrompt = PromptBuilder.chat(
      catalog: catalog,
      systemPromptFragments: const [_clinicalPrompt],
    ).systemPromptJoined();

    return _model ??= FirebaseAI.googleAI().generativeModel(
      model: 'gemini-3.1-flash-lite',
      systemInstruction: Content.system(systemPrompt),
      generationConfig: GenerationConfig(
        temperature: 0.35,
        maxOutputTokens: 4096,
      ),
    );
  }

  void _initGenUI() {
    surfaceController = SurfaceController(
      catalogs: [buildKlinikaCatalog()],
    );
    transport = A2uiTransportAdapter(onSend: _onSendToGemini);
    conversation = Conversation(
      controller: surfaceController,
      transport: transport,
    );

    _conversationSubscription = conversation.events.listen((event) {
      if (event is ConversationSurfaceAdded) {
        errorMessage.value = null;
        _rememberSurface(event.definition);
        if (!surfaceIds.contains(event.surfaceId)) {
          surfaceIds.add(event.surfaceId);
        }
        _refreshMainInputVisibility();
        _scrollToLatest();
      } else if (event is ConversationComponentsUpdated) {
        errorMessage.value = null;
        _rememberSurface(event.definition);
        if (!surfaceIds.contains(event.surfaceId)) {
          surfaceIds.add(event.surfaceId);
        }
        _refreshMainInputVisibility();
        _scrollToLatest();
      } else if (event is ConversationSurfaceRemoved) {
        surfaceIds.remove(event.surfaceId);
        lockedSurfaceIds.remove(event.surfaceId);
        _surfaceHasInteractiveInput.remove(event.surfaceId);
        _refreshMainInputVisibility();
      } else if (event is ConversationError) {
        _showError(
          'Je n ai pas pu afficher la fiche generee. Reessayez avec une phrase plus courte.',
        );
      }
    });
  }

  Future<void> _onSendToGemini(ChatMessage message) async {
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();
    final submittedSurfaceId = _submittedSurfaceId(message);
    if (submittedSurfaceId != null) {
      _lockSurface(submittedSurfaceId);
    }
    final surfaceCountBeforeRequest = surfaceIds.length;
    final promptText = _messageToGeminiText(message);
    _history.add(Content.text(promptText));
    _trimHistory();
    errorMessage.value = null;
    isLoading.value = true;
    try {
      final responseBuffer = StringBuffer();
      final stream = _ensureFirebaseAI().generateContentStream(_history);

      await for (final chunk in stream) {
        final text = chunk.text ?? '';
        if (text.isEmpty) continue;
        responseBuffer.write(text);
        transport.addChunk(text);
      }

      final responseText = responseBuffer.toString();
      if (responseText.isNotEmpty) {
        _history.add(Content.model([TextPart(responseText)]));
        _trimHistory();
      }

      await Future<void>.delayed(const Duration(milliseconds: 350));
      final readableText = _readableTextFrom(responseText);
      if (readableText.isNotEmpty) {
        assistantMessages.add(readableText);
        hasStarted.value = true;
        _refreshMainInputVisibility(forceShow: true);
        _scrollToLatest();
      }

      if (surfaceIds.length == surfaceCountBeforeRequest) {
        if (readableText.isEmpty) {
          _showError(
            'Gemini a repondu, mais la fiche n etait pas au format A2UI v0.9. Reessayez.',
          );
        } else {
          errorMessage.value = null;
        }
      }
    } catch (error) {
      debugPrint('[klinika_ai] Gemini error: $error');
      _showError('Connexion Gemini impossible pour le moment. Reessayez.');
    } finally {
      isLoading.value = false;
    }
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty || isLoading.value) return;

    HapticFeedback.mediumImpact();
    hasStarted.value = true;
    conversation.sendRequest(ChatMessage.user(text));
    textController.clear();
    _scrollToLatest();
  }

  void resetSession() {
    HapticFeedback.selectionClick();
    surfaceIds.clear();
    lockedSurfaceIds.clear();
    assistantMessages.clear();
    hasStarted.value = false;
    isLoading.value = false;
    shouldHideMainInput.value = false;
    textController.clear();
    errorMessage.value = null;
    _history.clear();
    _surfaceHasInteractiveInput.clear();
    _disposeGenUI();
    _initGenUI();
  }

  void clearError() {
    errorMessage.value = null;
  }

  void _showError(String message) {
    HapticFeedback.heavyImpact();
    errorMessage.value = message;
    _scrollToLatest();
  }

  String _messageToGeminiText(ChatMessage message) {
    final text = message.text.trim();
    if (text.isNotEmpty) {
      return text;
    }

    return '''
The user interacted with the generated UI. Continue the intake using this A2UI action/event payload:
${const JsonEncoder.withIndent('  ').convert(message.toJson())}

If one more focused question is clinically necessary, respond with a new A2UI v0.9 surface.
If you now have enough context, stop generating UI and provide a friendly final structured response with the recommended urgency, service, and next steps. Do not ask for more input in that final response.
''';
  }

  String? _submittedSurfaceId(ChatMessage message) {
    if (message.text.trim().isNotEmpty) return null;

    for (final part in message.parts.uiInteractionParts) {
      final decoded = jsonDecode(part.interaction);
      if (decoded is! Map<String, Object?>) continue;
      final action = decoded['action'];
      if (action is! Map<String, Object?>) continue;
      final surfaceId = action['surfaceId'];
      if (surfaceId is String && surfaceId.isNotEmpty) {
        return surfaceId;
      }
    }

    return surfaceIds.isEmpty ? null : surfaceIds.last;
  }

  void _lockSurface(String surfaceId) {
    if (!lockedSurfaceIds.contains(surfaceId)) {
      lockedSurfaceIds.add(surfaceId);
    }
    _refreshMainInputVisibility();
  }

  void _rememberSurface(SurfaceDefinition definition) {
    _surfaceHasInteractiveInput[definition.surfaceId] =
        definition.components.values.any(_isInteractiveComponent);
  }

  bool _isInteractiveComponent(Component component) {
    const interactiveTypes = {
      'Button',
      'Checkbox',
      'ChoicePicker',
      'ClinicalTextInput',
      'DatePicker',
      'DurationSelector',
      'PainScale',
      'Radio',
      'Select',
      'Slider',
      'Switch',
      'TextField',
      'YesNoCheck',
    };

    return interactiveTypes.contains(component.type) ||
        component.properties.containsKey('action') ||
        component.properties.containsKey('onSubmittedAction');
  }

  void _refreshMainInputVisibility({bool forceShow = false}) {
    if (forceShow || surfaceIds.isEmpty) {
      shouldHideMainInput.value = false;
      return;
    }

    for (final surfaceId in surfaceIds.reversed) {
      if (lockedSurfaceIds.contains(surfaceId)) continue;
      shouldHideMainInput.value =
          _surfaceHasInteractiveInput[surfaceId] ?? false;
      return;
    }

    shouldHideMainInput.value = false;
  }

  String _readableTextFrom(String responseText) {
    final withoutJsonFences = responseText.replaceAll(
      RegExp(r'```json[\s\S]*?```', caseSensitive: false),
      '',
    );
    final withoutOtherFences = withoutJsonFences.replaceAll(
      RegExp(r'```[\s\S]*?```', caseSensitive: false),
      '',
    );
    final cleaned = withoutOtherFences.trim();
    if (cleaned.isEmpty) return '';
    if (cleaned.startsWith('{') && cleaned.endsWith('}')) return '';
    return cleaned;
  }

  void _trimHistory() {
    const maxItems = 10;
    if (_history.length <= maxItems) return;
    _history.removeRange(0, _history.length - maxItems);
  }

  void lightTap() {
    HapticFeedback.selectionClick();
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!chatScrollController.hasClients) return;
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _disposeGenUI() {
    _conversationSubscription?.cancel();
    conversation.dispose();
    transport.dispose();
    surfaceController.dispose();
  }

  @override
  void onClose() {
    textController.dispose();
    chatScrollController.dispose();
    _disposeGenUI();
    super.onClose();
  }
}
