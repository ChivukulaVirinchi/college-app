defmodule Counselling.Ranks do
  import Ecto.Query, warn: false

 alias Counselling.CollegePrograms.CollegeProgram
  alias Counselling.Ranks.RankCutoff


  def get_rank_cutoffs(college_id, program_id) do
    from rc in RankCutoff,
      join: cp in CollegeProgram,
      on: cp.id == rc.college_program_id,
      where: cp.college_id == ^college_id and cp.program_id == ^program_id,
      order_by: [asc: rc.opening_rank]
  end
end
