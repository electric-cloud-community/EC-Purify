
# Data that drives the create step picker registration for this plugin.
my %runPurify = (
    label       => "Purify - Run Purify",
    procedure   => "runPurify",
    description => "Integrates Rational Purify Code Analisys tool into Electric Commander",
    category    => "Code Analysis"
);

$batch->deleteProperty("/server/ec_customEditors/pickerStep/Purify");
$batch->deleteProperty("/server/ec_customEditors/pickerStep/Purify - Run Purify");

@::createStepPickerSteps = (\%runPurify);