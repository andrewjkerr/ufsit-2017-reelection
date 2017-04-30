require 'csv'

#####
# Command line options
#####
if ARGV.size != 1
  puts "Please specify a CSV file."
  exit
end

#####
# Parse CSV with voting results
#####

# Did a current candidate already win another position?
candidates_already_won = []

# The data from the votes!
data = []

# Go row by row and figure out the rank for each candidate for each voter.
CSV.foreach(ARGV[0]) do |row|
  data << []
  row.each_with_index do |rank_str, index|
    # Gotta add one to the index.
    candidate = index + 1
    next if candidates_already_won.include?(candidate)

    # Convert the rank string to an integer
    case rank_str
    when "Best candidate"
      rank = 0
    when "Second best candidate"
      rank = 1
    when "Third best candidate"
      rank = 2
    when "Fourth best candidate"
      rank = 3
    when "Fifth best candidate"
      rank = 4
    else
      throw "Something is screwy with this rank: #{rank_str}"
    end

    # Rank the candidate!
    data.last[rank] = candidate
  end

  # Get rid of nulls
  data.last.compact!
end

#####
# Ranked voting
#####

# By now, we should have a data array that looks like this:
#
# data = [
#   [1, 2, 4, 3],
#   [2, 1, 4, 3],
#   [4, 1, 2, 3],
#   ...
# ]
#
# where each index of the data array is a voter's ballot
# and each index of a voter's ballot is the "ranked" votes
# in order.
#
# For example, `data.first` has:
#   - "Candidate #1" ranked first
#   - "Candidate #2" ranked second
#   - "Candidate #4" ranked third
#   - "Candidate #3" ranked fourth


# Track number of rounds.
current_round_number = 0

# Track eliminated candidates
eliminated = []

while true do
  current_round_number += 1
  puts "Current round: #{current_round_number}"

  # Set up a Hash to keep track of the count of candidates.
  current_round = {}

  # Count up the votes of this round!
  data.each do |ranking|
    while eliminated.include?(ranking.first)
      ranking.shift
    end

    vote = ranking.first
    current_round[vote] ||= 0
    current_round[vote] += 1
  end

  # Determine if we have a winner. If we do, exit. If we don't find the candidates
  # with the least number of votes to eliminate.

  # An array to keep track of the least voted for candidates.
  # If candidates are tied for lowest, discard all of their first choice votes.
  smallest_indices = []
  smallest_percentage = 100
  current_round.each do |candidate, num_votes|
    percentage_vote = (num_votes.to_f / data.size)
    puts "#{candidate} has #{percentage_vote} of the vote."

    # Did a candidate win a majority?
    if percentage_vote > 0.5
      puts "#{candidate} has won with #{percentage_vote} of the vote!"
      exit
    end

    # Does the current candidate have the lowest amount of votes?
    if percentage_vote < smallest_percentage
      smallest_indices = [candidate]
      smallest_percentage = percentage_vote
    elsif percentage_vote == smallest_percentage
      smallest_indices << candidate
    else
      # Continue onwards; we don't need to do anything.
    end
  end

  puts "Eliminating #{smallest_indices} (#{smallest_percentage} of the vote)"
  puts "---"

  # No one won so let's kill the lowest votes and shift.
  data.each_with_index do |ranking, index|
    ranking.shift if smallest_indices.include?(ranking.first)
  end

  eliminated.concat(smallest_indices)
end
