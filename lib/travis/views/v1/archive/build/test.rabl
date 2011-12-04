object @job

attributes :id, :number, :config

node(:started_at)  { @job.started_at }
node(:finished_at) { @job.finished_at }
node(:log)         { @job.log.content }
