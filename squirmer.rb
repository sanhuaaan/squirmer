defonce :knb_sampler do
  ##| knb_sampler={}
  ##| 8.times do |i|
  ##|   knb_sampler[21+i]=0
  ##|   knb_sampler[41+i]=1
  ##| end
  {21 => 0, 22=>0, 23=>0, 24=>0, 25=>0, 26=>0, 27=>0,
   41 => 1, 42=>1, 43=>1, 44=>1, 45=>1, 46=>1, 47=>1}
end

defonce :fx_sampler do
  {114 => 0, 115=>0, 116=>0, 117=>0}
end

defonce :pitch_amp do
  {'pitch' => 0, 'amp'=> 1}
end

defonce :loop_s do
  {'loop' => 0}
end

sampler_s=nil
fx_bitcrusher=nil
fx_echo=nil
fx_reverb=nil
fx_flanger=nil

live_loop :midi_sample do
  use_real_time
  sample_num, velocity = sync "/midi/launch_control/0/16/note_on"
  sample_num-=12 if sample_num > 24
  if sample_num < 16
    loop do
      with_fx :bitcrusher, mix: fx_sampler[114], bits: 4 do |fx_b|
        with_fx :echo, mix: fx_sampler[115], decay: 4 do |fx_e|
          with_fx :reverb, mix: fx_sampler[116] do |fx_r|
            with_fx :flanger, mix: fx_sampler[117], feedback: 0.9, phase: 0.5 do |fx_f|
              fx_bitcrusher=fx_b
              fx_echo=fx_e
              fx_reverb=fx_r
              fx_flanger=fx_f
              sampler_s = sample 'D:\Sonic Pi samples\sampler', sample_num-9,
                start: knb_sampler[sample_num+12],
                finish: knb_sampler[sample_num+32],
                window_size: 0.5, time_dis: 0.5, #pitch_dis: 0.5,
                pitch: pitch_amp['pitch'],
                amp: pitch_amp['amp']
            end
          end
        end
      end
      len=(sample_duration 'D:\Sonic Pi samples\sampler', sample_num-9)
      s=(len*knb_sampler[sample_num+12])
      f=(len*knb_sampler[sample_num+32])
      ####################################
      ####################################
      if loop_s['loop'] == 1
        if (f-s).abs < 0.125
          control sampler_s, beat_stretch: 0.125
          sleep 0.125
        else
          sleep (f-s).abs
        end
      end
      break if loop_s['loop'] == 0
    end
    
    
  else
    set :loop_s, 1
    print get[:loop_s]
    
  end
end

live_loop :midi_sample_knob do
  use_real_time
  n, val = sync "/midi/launch_control/0/16/control_change"
  if n == 28
    control sampler_s, pitch: (val/128.0)*7.5
    pitch_amp['pitch'] = ((val/128.0)*24) - 12
    puts ((val/128.0)*24) - 12
  elsif n == 48
    control sampler_s, amp: (val/128.0)*4
    pitch_amp['amp'] = (val/128.0)*4
  elsif n < 111
    knb_sampler[n]=val/128.0
  else
    fx_sampler[n] = fx_sampler[n] == 1 ? 0 : 1 if (val==127)
    
    case n
    when 114
      control fx_bitcrusher, mix: fx_sampler[114]
    when 115
      control fx_echo, mix: fx_sampler[115]
    when 116
      control fx_reverb, mix: fx_sampler[116]
    when 117
      control fx_flanger, mix: fx_sampler[117]
    end
  end
end

live_loop :loop_control do
  use_real_time
  sample_num, velocity = sync "/midi/launch_control/0/16/note_on"
  if sample_num == 28
    loop_s['loop'] = loop_s['loop'] == 1 ? 0 : 1
  end
end
