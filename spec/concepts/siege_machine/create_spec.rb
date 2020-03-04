require 'rails_helper'

RSpec.describe SiegeMachine::Create do
  subject { described_class.call camp: camp, siege_machine_type: type }

  let(:camp) { create :camp }
  let(:assembled_machine) { subject[:assembled_siege_machine] }

  shared_examples 'a valid configuration' do |machine_type|
    let(:type) { machine_type }
    let(:config) { Rails.configuration.siege_machines[machine_type.to_sym] }

    it { is_expected.to be_success }

    its([:error]) { is_expected.to be_nil }

    it 'builds a new weapon' do
      expect { subject }.to change(camp.siege_machines, :count).by 1
    end

    it 'returns the new weapon' do
      expect(assembled_machine).to be_persisted
    end

    it 'builds a machine o the expected type' do
      expect(assembled_machine.siege_machine_type).to eq type
    end

    it 'belongs to the right camp' do
      expect(assembled_machine.camp).to be camp
    end

    it 'build a new weapon with a random name' do
      expect(assembled_machine.name).to be_a String
      expect(assembled_machine.name.size).to be >= 5
    end

    it 'has a minimum damages' do
      expect(assembled_machine.damages).to be >= config[:minimum_damages]
    end

    it 'is below the maximum damages' do
      expect(assembled_machine.damages).to be <= config[:maximum_damages]
    end

    it 'respect the damage step definition' do
      expect(assembled_machine.damages % config[:step_damages]).to be 0
    end

    it 'has one ongoing task' do
      expect(assembled_machine.ongoing_tasks).to have_exactly(1).items
    end
  end

  it_behaves_like 'a valid configuration', 'catapult'
  it_behaves_like 'a valid configuration', 'ballista'
  it_behaves_like 'a valid configuration', 'trebuchet'

  context 'when there is a nested error' do
    before do
      allow(Rails.configuration).to receive(:siege_machines)
        .and_return(
          {
            catapult: {
              minimum_damages: 50,
              maximum_damages: 100,
              step_damages: 10,
              ongoing_tasks: [{
                type: 'NOT_A_TASK',
                action_points_required: 10,
                repeatable: true
              }]
            }
          }
        )
    end

    let(:type) { 'catapult' }

    it { is_expected.to be_failure }

    it 'sets an error' do
      expect(subject[:error]).to eq 'NOT_A_TASK is not a class'
    end

    it 'does not build anything' do
      expect { subject }.not_to change(SiegeMachine, :count)
    end

    it 'does not return anyhting' do
      expect(assembled_machine).to be_nil
    end
  end

  describe 'building a duck' do
    let(:type) { 'duck' }

    it { is_expected.to be_failure }

    it 'sets an error' do
      expect(subject[:error]).to eq 'duck type is not found'
    end

    it 'does not build anything' do
      expect { subject }.not_to change(SiegeMachine, :count)
    end

    it 'does not return anyhting' do
      expect(assembled_machine).to be_nil
    end
  end
end