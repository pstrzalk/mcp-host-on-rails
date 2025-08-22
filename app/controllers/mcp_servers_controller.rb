class McpServersController < ApplicationController
  before_action :set_mcp_server, only: [:destroy]
  
  def index
    @mcp_servers = McpServer.ordered
    @mcp_server = McpServer.new
  end
  
  def create
    @mcp_server = McpServer.new(mcp_server_params)
    
    if @mcp_server.save
      redirect_to mcp_servers_path, notice: 'MCP server added successfully'
    else
      @mcp_servers = McpServer.ordered
      render :index, status: :unprocessable_entity
    end
  end
  
  def destroy
    @mcp_server.destroy
    redirect_to mcp_servers_path, notice: 'MCP server removed successfully'
  end
  
  private
  
  def set_mcp_server
    @mcp_server = McpServer.find(params[:id])
  end
  
  def mcp_server_params
    params.require(:mcp_server).permit(:name, :url)
  end
end