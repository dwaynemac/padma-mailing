require 'spec_helper'

describe Template do
  it { should validate_presence_of :subject }
  it { should validate_presence_of :name }

  it { should belong_to(:account).with_foreign_key(:local_account_id)}
  it { should validate_presence_of :account }

  describe "#needed_data" do
    subject{template.needed_data}
    let(:template){build(:template, content: content)}
    context "when content has multiple tags" do
      let(:content){"%{header} hello %{contact.first_name}, this is a mail {false variabl}. %{contact.instructor.signature}"}
      it "returns liquid variables used in content" do
        should eq [
          'header',
          'contact' => [
            'first_name',
            'instructor' => ['signature']
          ]
        ] 
      end
      it "returns a Array" do
        should be_a Array
      end
    end
    shared_examples_for 'no content' do
      it "returns be empty" do
        should be_empty
      end
      it "returns a Array" do
        should be_a Array
      end
    end
    context "when content has no tags" do
      let(:content){"text withou {valid} tags"}
      include_examples 'no content'
    end
    context "when content is empty" do
      let(:content){""}
      include_examples 'no content'
    end
    context "when content is nil" do
      let(:content){nil}
      include_examples 'no content'
    end
  end
  
  describe "a normal template" do
    it "should be able to save a large content" do
      content = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla dui odio, tincidunt nec vulputate sit amet, malesuada in quam. Integer congue felis nec mauris feugiat eu tristique augue eleifend. Duis auctor est eu sapien ultrices pellentesque. In ut lorem mi. Aenean at velit ac metus fermentum interdum. Curabitur condimentum nisl vitae dolor cursus interdum. Donec tristique, mauris et euismod dignissim, libero elit dignissim est, sed imperdiet mi est id nisi. In cursus volutpat mattis. Mauris commodo malesuada risus vel eleifend. Mauris et eros libero.
In feugiat fermentum mattis. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam et risus purus, et egestas felis. Aenean mattis facilisis nisl in aliquam. Aenean auctor, metus a pulvinar fringilla, diam arcu accumsan tellus, et viverra erat nulla eget tellus. Quisque semper orci odio. Curabitur non nunc vel ante sollicitudin pharetra eget sed justo. Ut sagittis eros eu massa blandit laoreet. Nunc non blandit lorem. Suspendisse arcu massa, convallis in egestas id, accumsan ullamcorper nibh. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Morbi sed magna orci. Vestibulum vestibulum ultricies odio in egestas. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.
Fusce vehicula imperdiet mollis. Etiam dapibus imperdiet tempor. Curabitur semper orci ac tellus iaculis congue. Nam sit amet enim a arcu adipiscing molestie. Nam quam lorem, convallis eu fermentum et, tempus a neque. In hac habitasse platea dictumst. Curabitur quam est, cursus convallis sollicitudin vitae, pulvinar eget mi.
Curabitur fermentum libero et nisl condimentum non rhoncus eros facilisis. Curabitur eget tortor nulla, vel faucibus massa. In eu massa eu augue imperdiet aliquam. Vivamus non nisi nisi, a ullamcorper neque. Phasellus congue, felis vel tempus blandit, dolor elit porta leo, et rutrum leo justo sed massa. Nulla feugiat fringilla varius. Maecenas vel elit orci.
Mauris enim risus, porta nec fringilla tristique, sagittis vitae massa. Curabitur fermentum lobortis nisi vitae convallis. Vestibulum blandit risus velit. Mauris nec nulla purus, eget pretium libero. Fusce lacus felis, blandit et pellentesque sit amet, viverra non nulla. Nulla facilisi. Nam nec varius arcu. Nullam laoreet massa tellus, at malesuada massa. Sed condimentum nulla vitae lorem consequat consequat. Donec gravida, ligula suscipit vestibulum feugiat, urna augue venenatis sem, eu scelerisque nisi tortor imperdiet magna. Sed mattis, dui vehicula mollis interdum, felis nulla ornare nibh, ac dignissim turpis velit non tellus. Aenean pretium blandit euismod. Quisque vitae nisi neque. Sed vulputate volutpat libero, in varius ligula scelerisque in. Curabitur aliquet tempus mi, vel sagittis felis aliquam non. Etiam accumsan dapibus ante non molestie."
      account = FactoryGirl.create(:account)
      template = Template.new(name: "new_template", subject: "this_subject", content: content)
      template.account = account

      expect{template.save}.to change{Template.count}.by(1)
    end
  end
end
