# I am storing all my homedir in a git repository because when I attempted to
# automate this with chef, I created a massively over-engineered beast.

home_dir      = node[:workstation][:home]
home_dir_repo = node[:workstation][:git_homedir][:repo]
git_branch    = node[:workstation][:git_homedir][:branch]
current_user  = node[:workstation][:user]
git_dir       = File.join(home_dir, '.git')


execute "initialize git repository" do
  cwd home_dir
  user current_user
  command 'git init'
  not_if { File.exists?(git_dir) }
end

execute "add homedir repo as a remote" do
  cwd home_dir
  user current_user
  command "git remote add origin #{home_dir_repo}"
  not_if "cd #{home_dir} && git remote | grep origin"
end

execute "fetching remote objects" do
  cwd home_dir
  user current_user
  command "git fetch origin #{git_branch}"
end

execute "ensure submodules are fetched" do
  cwd home_dir
  user current_user
  command 'git fetch --all'
end

execute "ensure #{git_branch} is at tip" do
  cwd home_dir
  user current_user
  command "git reset --hard origin/#{git_branch}"
end

execute "fetch our submodules" do
  cwd home_dir
  user current_user
  command 'git submodule update --init'
end

