guard 'shell' do
  watch(/^BSMInputMethod\/(.*).(m|h|mm|hh)/) do |info|
    filename = File.basename(info[1])
    if Dir["BSMInputMethodTests/**/#{filename}Spec.m"].size > 0
      system("xctool test -only BSMInputMethodTests:#{filename}Spec")
    end
  end

  watch(/^BSMInputMethodTests\/(.*).(m|h|mm|hh)/) do |info|
    filename = File.basename(info[1])
    system("xctool test -only BSMInputMethodTests:#{filename}")
  end
end
