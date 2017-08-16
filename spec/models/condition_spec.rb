require 'spec_helper'

describe Condition do
  it { should belong_to :trigger }
  it { should validate_presence_of :key }
  it { should validate_presence_of :value }
end
