require 'clockwork'
require 'git'
require 'logger'

module Clockwork

  handler do |job|

  end

  every(1.week, 'list.update') # at: "Monday 08:00"
end
