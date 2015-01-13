class KindsController < ApplicationController
def index
	puts ActiveRecord::Base.connection.current_database
	@kinds = Kind.all
  end
end
