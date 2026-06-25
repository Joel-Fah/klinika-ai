import 'package:genui/genui.dart';

import 'widgets/care_summary.dart';
import 'widgets/clinical_text_input.dart';
import 'widgets/department_selector.dart';
import 'widgets/duration_selector.dart';
import 'widgets/pain_scale.dart';
import 'widgets/symptom_chip_group.dart';
import 'widgets/triage_banner.dart';
import 'widgets/yes_no_check.dart';

Catalog buildKlinikaCatalog() {
  return BasicCatalogItems.asNoAssetCatalog().copyWith(newItems: [
    buildTriageBannerItem(),
    buildDepartmentSelectorItem(),
    buildSymptomChipGroupItem(),
    buildCareSummaryItem(),
    buildClinicalTextInputItem(),
    buildPainScaleItem(),
    buildDurationSelectorItem(),
    buildYesNoCheckItem(),
  ]);
}
