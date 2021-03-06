# This controller handles all calls for staff information.

class UsersController < ApplicationController
  before_filter :require_user, :only => [:edit]

  skip_before_filter :deny_access_to_all
  access_control do
    actions :index, :show do
      allow all
    end
    action :edit do
      allow logged_in
    end
  end


  # The index method simply lists all staff members, ordered by their last name.
  def index
    @users = User.all :order => "lastname"
  end

  # Whenever a logged in user wants to change its profile information, this action is responsible.
  def edit
    @user = current_user

    @project_board_votes = @user.project_board_votes
    #ToDo make it better, better scope, soon with rails 3
    @project_board_votes.reject!{|element| element.paperproposal.board_state == "accept" ||
                                           element.paperproposal.board_state == "final"}
    @project_board_votes.sort!{|a,b| a.paperproposal <=> b.paperproposal}

    @to_vote = @user.for_paperproposal_votes
    #ToDo make it better, better scope, soon with rails 3
    @to_vote.reject!{|element| element.paperproposal.board_state == "final"}
    @to_vote.sort!{|a,b| a.paperproposal <=> b.paperproposal}

    @data_requests = Paperproposal.find_all_by_board_state("submit").sort
  end

  # The show method provides all informations about one specific person.
  def show
    redirect_to(:action => "index") and return if params[:id].blank?

    u_id = params[:id].split(/-/).first
    @user = User.find u_id

    @user_datasets_owned = @user.datasets_owned.sort_by {|d| d.title.to_s}

    redirect_to(:action => "index", :status => :not_found) unless @user
  end

end
