touchpad_id = `xinput list | grep Touchpad`
id = touchpad_id.split[4].split('=')[1].to_i
# puts id
props = `xinput list-props #{id} | grep 'Tapping Enabled'`
prop_id = props.split[3][1..-3].to_i
`xinput set-prop #{id} #{prop_id} 1`
