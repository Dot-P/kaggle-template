import yaml
import wandb

with open("config.yaml") as f:
    config = yaml.safe_load(f)

wandb.init(
    project=config["project"],
    group=config["experiment_name"],
    name=f"{config['experiment_name']}_fold{config['fold']}",
    config=config
)