touchpad_id = `xinput list | grep Touchpad`
valid = touchpad_id.split.select {|x| x.start_with?("id=")}
id = touchpad_id.split('=')[1].to_i
props = `xinput list-props #{id} | grep 'Tapping Enabled'`
prop_id = props.split[3][1..-3].to_i
`xinput set-prop #{id} #{prop_id} 1`
