
# This is a quick hack to enable the creation of story
# centered rspec tests.  Each story is implemented as
# a class derived from StorySpec.  Each step in the story
# is implemented as a method on the StorySpec.  The
# method should look like:
#
# def s1_MyMethod
#     define spec_name("String identifying step goes here.")
#     it "should do whatever" do
#     ...
#     end
# end
#
# At the end of the class you must call run_specs.
# All of the methods beginning with s[some number]_
# (i.e., s1_, s2_, s101_, etc) will be run.
class StorySpec
    def spec_name(string)
        self.class.name.to_s + " - " + string
    end

    class << self
        
        def run_specs
            obj = self.new
            obj.methods.each do |method|
                if method =~ /^s\d*[_]/
                    eval("obj." + method)
                end
            end
        end
        
    end
end
