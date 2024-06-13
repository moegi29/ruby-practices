# frozen_string_literal: true

require_relative './frame'
class Game
  def initialize(shot_instances)
    @shot_instances = shot_instances
  end

  def score
    @frames = build_frames
    game_score = 0
    10.times do |idx|
      frame = @frames[idx]
      game_score += frame.score
      game_score += calculate_bonus_point(idx, frame)
    end
    game_score
  end

  def build_frames
    frames = []
    i = 0
    while i < @shot_instances.size
      if frames.size < 9
        if @shot_instances[i] == 'X'
          frames << Frame.new('X', '0')
          i += 1
        else
          frames << Frame.new(@shot_instances[i], @shot_instances[i + 1])
          i += 2
        end
      else
        frames << Frame.new(@shot_instances[i], @shot_instances[i + 1], @shot_instances[i + 2])
        break
      end
    end
    frames
  end

  def calculate_bonus_point(idx, frame)
    return 0 if idx >= 9

    if frame.strike?
      next_frame = @frames[idx + 1]
      next_two_frame = @frames[idx + 2]
      if next_frame.strike? && next_two_frame
        [next_frame.first_shot.score, next_two_frame.first_shot.score].sum
      else
        [next_frame.first_shot.score, next_frame.second_shot.score].sum
      end
    elsif frame.spare?
      @frames[idx + 1].first_shot.score
    else
      0
    end
  end
end
shot_instances = ARGV[0].split(',')
game = Game.new(shot_instances)
puts game.score