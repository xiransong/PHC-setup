python phc/run_hydra.py \
  learning=im \
  env=env_im \
  robot=smpl_humanoid \
  env.motion_file=sample_data/amass_isaac_standing_upright_slim.pkl \
  env.num_envs=1 \
  headless=True \
  test=True \
  epoch=-1
