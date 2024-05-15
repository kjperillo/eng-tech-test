  # Create Virtual Network (VNet)
  resource "azurerm_virtual_network" "main" {
    name                = "tech-test-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = var.rg_location
    resource_group_name = var.rg_name
  
    tags = var.tags
  }
  
  # Create Public Subnet
  resource "azurerm_subnet" "public" {
    name                 = "public-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.1.0/24"]
  }
  
  # Create Private Subnet
  resource "azurerm_subnet" "private" {
    name                 = "private-subnet"
    resource_group_name  = var.rg_name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefixes     = ["10.0.2.0/24"]
  
  }
  
  # Create Public IP for the NAT Gateway
  resource "azurerm_public_ip" "nat" {
    name                = "nat-gateway-pip"
    resource_group_name = var.rg_name
    location            = var.rg_location
    allocation_method   = "Static"
    sku = "Standard"
  
    tags = var.tags
  }
  
  # Create NAT Gateway
  resource "azurerm_nat_gateway" "main" {
    name                = "main-nat-gateway"
    resource_group_name = var.rg_name
    location            = var.rg_location
  
    tags = var.tags
  }

  resource "azurerm_nat_gateway_public_ip_association" "ng_pub_ip_assoc" {
  nat_gateway_id       = azurerm_nat_gateway.main.id
  public_ip_address_id = azurerm_public_ip.nat.id
}
  
  # Associate NAT Gateway with Private Subnet
  resource "azurerm_subnet_nat_gateway_association" "private" {
    subnet_id      = azurerm_subnet.private.id
    nat_gateway_id = azurerm_nat_gateway.main.id
  }
  
  # Create Route Table for Public Subnet
  resource "azurerm_route_table" "public" {
    name                = "public-route-table"
    resource_group_name = var.rg_name
    location            = var.rg_location
  
    route {
      name                   = "default-route"
      address_prefix         = "0.0.0.0/0"
      next_hop_type          = "Internet"
    }
  
    tags = var.tags
  }
  
  # Associate Route Table with Public Subnet
  resource "azurerm_subnet_route_table_association" "public" {
    subnet_id      = azurerm_subnet.public.id
    route_table_id = azurerm_route_table.public.id
  }
  
  # Create Route Table for Private Subnet
  resource "azurerm_route_table" "private" {
    name                = "private-route-table"
    resource_group_name = var.rg_name
    location            = var.rg_location
  
    tags = var.tags
  }
  
  # Associate Route Table with Private Subnet
  resource "azurerm_subnet_route_table_association" "private" {
    subnet_id      = azurerm_subnet.private.id
    route_table_id = azurerm_route_table.private.id
  }
  