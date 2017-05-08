
import logging
from gym.envs.registration import register
from gym.envs.vmware_env.vmware_env import VMwareEnv
from gym.envs.vmware_env.esxtest_env import ESXTestEnv

logger = logging.getLogger(__name__)

# Virtualization
# ----------------------------------------


#register(
#    id='VirtESX-v0',
#    entry_point='gym.envs.vmware_env:VMwareEnv',
#    # More arguments here
#)