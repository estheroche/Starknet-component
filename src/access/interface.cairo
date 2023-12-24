use starknet::ContractAddress;

const IACCESSCONTROL_ID: felt252 =
    0x23700be02858dbe2ac4dc9c9f66d0b6b0ed81ec7f970ca6844500a56ff61751;

#[starknet::interface]
trait IAccessControl<TContractState>{
    fn has_role(self:@TContractState, role:felt252, account:ContractAddress) -> bool;
    fn get_role_admin(self:@TContractState,role:felt252) -> felt252;
    fn grant_role(ref self:TContractState, role:felt252, account:ContractAddress);
    fn revoke_role(ref self:TContractState, role:felt252, account:ContractAddress);
    fn renounce_role(ref self:TContractState, role:felt252, account:ContractAddress);
}