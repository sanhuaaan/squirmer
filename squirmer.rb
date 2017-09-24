defonce :dfonc do
  {
    #knobs
    21 => 0, 22=>0, 23=>0, 24=>0, 25=>0, 26=>0, 27=>1,
    41 => 1, 42=>1, 43=>1, 44=>1, 45=>1, 46=>1,
    #fx
    114 => 0, 115=>0, 116=>0, 117=>0,
    
    'pitch' => 0, 'amp'=> 1,
    'loop' => 0,
    'sampler_s' => nil,
    'fx_bitcrusher'=> nil,
    'fx_echo'=> nil,
    'fx_reverb'=> nil,
    'fx_flanger'=> nil,
    'fx_rm'=> nil,
    'pan' => 0,
    'sample_page' => 0
  }
end

##| defonce :pad_map do
##|   {9 => 0,10 => 0,11 => 0,12 => 0,25 => 0,26 => 0}
##| end


current_pad=nil
current_page=0
midi_note_on 28, 3, port: "launch_control" if current_pad == nil
midi_note_on 27, 21, port: "launch_control" if current_pad == nil #21/23


live_loop :sample do
  use_real_time
  sample_num, velocity = sync "/midi/launch_control/0/16/note_on"
  if sample_num < 27 and (sample_num != current_pad or current_page != dfonc['sample_page'])
    midi_note_on current_pad, 0, port: "launch_control" if current_page == dfonc['sample_page']
    midi_note_on sample_num, 127, port: "launch_control"
    current_pad = sample_num
    current_page = dfonc['sample_page']
  end
  sample_num-=12 if sample_num > 24
  if sample_num < 15
    loop do
      puts dfonc[27]
      with_fx :ring_mod, freq: dfonc[27] == 0 ? 1 : dfonc[27], mix: dfonc[27] == 1 ? 0 : 1 do |fx_rm|
        with_fx :bitcrusher, mix: dfonc[114], bits: 4 do |fx_b|
          with_fx :echo, mix: dfonc[115], decay: 4 do |fx_e|
            with_fx :reverb, mix: dfonc[116] do |fx_r|
              with_fx :flanger, mix: dfonc[117], feedback: 0.9, phase: 0.5 do |fx_f|
                dfonc['fx_rm']=fx_rm
                dfonc['fx_bitcrusher']=fx_b
                dfonc['fx_echo']=fx_e
                dfonc['fx_reverb']=fx_r
                dfonc['fx_flanger']=fx_f
                dfonc['sampler_s'] = sample 'D:\Sonic Pi samples\sampler', (sample_num-9) + dfonc['sample_page']*6,
                  start: dfonc[sample_num+12],
                  finish: dfonc[sample_num+32],
                  window_size: 0.5, time_dis: 0.5, #pitch_dis: 0.5,
                  pitch: dfonc['pitch'],
                  amp: dfonc['amp'],
                  pan: dfonc['pan']
              end
            end
          end
        end
      end
      len=(sample_duration 'D:\Sonic Pi samples\sampler', sample_num-9)
      s=(len*dfonc[sample_num+12])
      f=(len*dfonc[sample_num+32])
      if dfonc['loop'] == 1
        if (f-s).abs < 0.15
          control dfonc['sampler_s'], beat_stretch: 0.125
          sleep 0.15
        else
          sleep (f-s).abs
        end
      end
      break if dfonc['loop'] == 0
    end
  end
end

live_loop :fx do
  use_real_time
  n, val = sync "/midi/launch_control/0/16/control_change"
  if n == 28
    control dfonc['sampler_s'], pitch: (val/128.0)*7.5
    dfonc['pitch'] = ((val/128.0)*24) - 12
    puts "Pitch: #{((val/128.0)*24) - 12}"
  elsif n == 48
    control dfonc['sampler_s'], amp: (val/128.0)*4
    dfonc['amp'] = (val/128.0)*4
  elsif n == 27 #freq ring_mod
    if val>0
      control dfonc['fx_rm'], freq: val, mix: 1
      dfonc[n]=val
    else
      control dfonc['fx_rm'], mix: 0
    end
  elsif n == 47 #
    control dfonc['sampler_s'], pan: ((val/128.0)*2) - 1
    dfonc['pan'] = ((val/128.0)*2) - 1
  elsif n < 111 #knobs
    dfonc[n]=val/128.0
  else #botones fx
    dfonc[n] = dfonc[n] == 1 ? 0 : 1 if (val==127)
    
    case n #fx
    when 114
      control dfonc['fx_bitcrusher'], mix: dfonc[114]
      midi_cc 114, (dfonc[114] * 3)
    when 115
      control dfonc['fx_echo'], mix: dfonc[115]
      midi_cc 115, (dfonc[115] * 3)
    when 116
      control dfonc['fx_reverb'], mix: dfonc[116]
      midi_cc 116, (dfonc[116] * 3)
    when 117
      control dfonc['fx_flanger'], mix: dfonc[117]
      midi_cc 117, (dfonc[117] * 3)
    end
  end
end

live_loop :loop_control do
  use_real_time
  sample_num, velocity = sync "/midi/launch_control/0/16/note_on"
  case sample_num
  when 28
    dfonc['loop'] = dfonc['loop'] == 1 ? 0 : 1
    midi_note_on 28, 3+(121*dfonc['loop']), port: "launch_control"
  when 27
    dfonc['sample_page'] = dfonc['sample_page'] == 1 ? 0 : 1
    midi_note_on 27, 21+(2*dfonc['sample_page']), port: "launch_control"
    midi_note_on current_pad, current_page == dfonc['sample_page'] ? 127 : 0, port: "launch_control"
  end
end