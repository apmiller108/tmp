class LlmToolsController < ApplicationController
  before_action :set_llm_tool, only: %i[show edit update destroy]

  def index
    @llm_tools = LlmTool.all
  end

  def new
    @llm_tool = LlmTool.new
  end

  def edit; end

  def create
    @llm_tool = LlmTool.new(llm_tool_params)

    respond_to do |format|
      if @llm_tool.save
        format.html { redirect_to llm_tools_path, notice: 'LLM tool was successfully created.' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @llm_tool.update(llm_tool_params)
        format.html { redirect_to llm_tools_path, notice: 'LLM tool was successfully updated.' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @llm_tool.destroy!

    respond_to do |format|
      format.html { redirect_to llm_tools_path, status: :see_other, notice: 'LLM tool was successfully destroyed.' }
    end
  end

  private

  def set_llm_tool
    @llm_tool = LlmTool.find(params.expect(:id))
  end

  def llm_tool_params
    params.expect(llm_tool: [:name, :description, :input_schema, :active])
  end
end
