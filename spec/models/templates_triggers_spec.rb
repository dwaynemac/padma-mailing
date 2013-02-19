require 'spec_helper'

describe TemplatesTriggers do
  it { should belong_to :trigger }
  it { should belong_to :template }
  it { should validate_presence_of :trigger }
  it { should validate_presence_of :template }
end
