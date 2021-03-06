class UnitsController < ApplicationController
  before_action :set_unit, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, except: [:show, :index]

  # GET /units
  # GET /units.json
  def index
    @units = Unit.all
  end

  # GET /units/1
  # GET /units/1.json
  def show
  end

  # GET /units/new
  def new
    @unit = Unit.new
  end

  # GET /units/1/edit
  def edit
    @users = User.all
    @properties = Property.all
  end

  # POST /units
  # POST /units.json
  def create
    @unit = Unit.new(unit_params)
      if @unit.save
        flash[:notice] = "Unit was successfully created."
        redirect_to admin_path
      else
        flash[:error] = "There was a problem saving the unit. Please ensure all fields are properly filled-in."
        redirect_to admin_path
      end

  end

  # PATCH/PUT /units/1
  # PATCH/PUT /units/1.json
  def update
      if @unit.update(unit_params)
        flash[:notice] = "Unit was successfully updated."
        redirect_to admin_path
        #format.html { redirect_to @unit, notice: 'Unit was successfully updated.' }
        #format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unit.errors, status: :unprocessable_entity }
      end
  end

  # DELETE /units/1
  # DELETE /units/1.json
  def destroy
    @unit.destroy
    respond_to do |format|
      format.html { redirect_to units_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unit
      @unit = Unit.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unit_params
      params.require(:unit).permit(:description, :rent_charge, :security_charge, :security_paid, :user_id, :property_id)
    end
end
