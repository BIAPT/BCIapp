%Full experiment structure
Experiment = struct();
Experiment.name = "";
Experiment.last_record = "";
Experiment.last_calibration = "";
Experiment.channels_left = {};
Experiment.channels_right = {};
Experiment.params = struct();
Experiment.params.is_calibrated = false;
Experiment.params.is_channel_selected = false;
Experiment.params.is_baseline_recording = false;
Experiment.params.is_action_recording = false;
Experiment.params.is_calculation = false;
Experiment.params.is_ready = false;
Experiment.recordings = [];

%Recording session structure
Recording = struct();
Recording.date = "";
Recording.participant_id = -1;
Recording.nb_trials = -1;
Recording.nb_blocks = -1;
Recording.pause_trials = -1;
Recording.pause_blocks = -1;
Recording.gravity = -1;
Recording.saving_dir = "";
Recording.data = struct();

%Data structure
Data.raw_participant_location = [];
Data.raw_real_location = [];
Data.processed_result = []

%EEG structure
EEG.baseline = [];
EEG.action = [];
EEG.calculation = [];
EEG.date = "";

BCI_app.experiment = Experiment;
BCI_app.recording = Recording
BCI_app.data = Data;
BCI_app.eeg = EEG;