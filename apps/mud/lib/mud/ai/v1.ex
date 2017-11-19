defmodule Mud.AI.V1 do
  # No. Weigh in possible choices then act on the best choice.
  def decide(state) do
    cond do
      dead?(state) -> wah_wah_waaah
      wanna_stay_here?(state) -> stay
      wanna_move?(state) -> move
      wanna_mate?(state) -> mate
    end
  end
end
