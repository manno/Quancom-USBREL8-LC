# run as daemon
#
# add RPC for simple control of relays
#
# load several Licht::ActionStacks with Licht::Action from lichtcontrol
#  using Licht::Script.load
#
# assign Licht::Rule to every script (start time, execution probability, ...)
# add custom shutoff rule: clears all rules, inclusive timers from stack
#   so nothing executes thereafter
#
# execute scripts according to Licht::Rules every n minutes
#
# keep state of all executed commands in log/db
