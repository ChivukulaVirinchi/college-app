defimpl Phoenix.Param, for: Counselling.Colleges.College do
  def to_param(%{id: id, slug: slug}) do
    "#{id}-#{slug}"
  end
end

defimpl Phoenix.Param, for: Counselling.Programs.Program do
  def to_param(%{id: id, slug: slug}) do
    "#{id}-#{slug}"
  end
end
