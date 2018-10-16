class SubsController < ApplicationController
  before_action :set_sub, only: %i[show update destroy]

  def index
    subs = Sub.all

    render json: SubSerializer.new(subs)
  end

  def show
    render json: SubSerializer.new(@sub)
  end

  def create
    sub = Sub.new(sub_params)

    if sub.save
      render json: SubSerializer.new(sub), status: :created
    else
      render json: sub.errors, status: :unprocessable_entity
    end
  end

  def update
    if @sub.update(sub_params)
      render json: SubSerializer.new(@sub)
    else
      render json: @sub.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @sub.destroy
  end

  private

  def set_sub
    @sub = Sub.find_by_name!(params[:name])
  end

  def sub_params
    params.require(:sub).permit(:name)
  end
end
