require 'spec_helper'

describe Filter do
  it { should belong_to :trigger }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
end
