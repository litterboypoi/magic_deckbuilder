extends Node

signal jobs_emepty

class AsyncJob:
	var owner: Node
	var id: int


var jobs: Array[AsyncJob] = []

func _gen_job_id(_owner: Node) -> int:
	return hash(str(_owner.get_instance_id()) + str(Time.get_ticks_msec()) + str(randi()))


func is_empty() -> bool:
	return jobs.size() == 0


func start_job(_owner: Node) -> int:
	var job = AsyncJob.new()
	job.owner = _owner
	job.id = _gen_job_id(_owner)
	jobs.append(job)

	if not _owner.tree_exited.is_connected(_on_node_exited_tree.bind(_owner)):
		_owner.tree_exited.connect(_on_node_exited_tree.bind(_owner))
	return job.id


func finish_job(job_id: int) -> void:
	for job in jobs:
		if job.id == job_id:
			jobs.erase(job)
			break
	if jobs.size() == 0:
		jobs_emepty.emit()


func _on_node_exited_tree(node: Node) -> void:
	for job in jobs:
		if job.owner == node:
			jobs.erase(job)
	if jobs.size() == 0:
		jobs_emepty.emit()
