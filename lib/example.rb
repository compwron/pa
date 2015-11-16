options = 'invaid options' #{}

begin
  a = if options[:foo]
        1
      else
        2
      end
  p a
rescue TypeError => e
  p "Threw TypeError #{e}"
end

def foo(options)
  if options[:foo]
    1
  else
    2
  end
end

begin
  p foo(options)
rescue TypeError => e
  p "Threw TypeError #{e}"
end
