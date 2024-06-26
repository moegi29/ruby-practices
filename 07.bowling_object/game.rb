# frozen_string_literal: true

require_relative './frame'

class Game
  def initialize(marks)
    @shot_instances = marks.map { |mark| Shot.new(mark) }
  end

  def score
    @frames = build_frames
    @frames.each_with_index.sum do |frame, idx|
      frame.score + calculate_bonus_point(idx, frame)
    end
  end

  private

  def build_frames
    frames = []
    i = 0
    while i < @shot_instances.size
      if frames.size < 9
        if @shot_instances[i].perfect_score
          frames << Frame.new(@shot_instances[i], Shot.new('0'))
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
