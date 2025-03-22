import os
import yaml
import wandb

# current directory
dir_path = os.path.dirname(os.path.realpath(__file__))
os.chdir(dir_path)

# Load config
with open("config.yaml") as f:
    config = yaml.safe_load(f)

# Initialize wandb
wandb.init(
    project=config["project"],
    group=config["experiment_name"],
    name=f"{config['experiment_name']}",
    config=config
)

wandb.finish()