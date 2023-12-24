use components::access::accesscontrol::AccessControl;
use components::access::accesscontrol::AccessControl::InternalImpl;
use components::interface::ISRC5Dispatcher;
use components::interface::ISRC5DispatcherTrait;
use starknet::ContractAddress;
use components::access::accesscontrol::AccessControl::AccessControlImpl;
use components::SRC5_Component::SRC5::SRC5Impl;
use components::access::interface::IACCESSCONTROL_ID;
use components::utils::constant::{
    ADMIN, ROLE, AUTHORIZED, OTHER_ROLE, pop_log, ZERO,DEFAULT_ADMIN, assert_no_events_left, drop_event
};
use starknet::get_caller_address;
use starknet::testing;
use debug::PrintTrait;
use components::access::accesscontrol::AccessControl::{RoleAdminChanged, RoleGranted};


fn STATE() -> AccessControl::ContractState {
    AccessControl::contract_state_for_testing()
}


fn setup() -> AccessControl::ContractState {
    let mut state = STATE();
    InternalImpl::_grant_role(ref state, DEFAULT_ADMIN, ADMIN());
    drop_event(ZERO());
    state
}

mod ERRORS {
    const INVALID_STATUS: felt252 = 'INVALID_STATUS';
    const NO_ROLE: felt252 = 'No role yet';
    const SHOULD_HAVE_ROLE: felt252 = 'should have role';
}

#[test]
#[available_gas(2000000)]
fn test_initializer() {
    let mut state = STATE();
    let init_param: felt252 = IACCESSCONTROL_ID;
    InternalImpl::initializer(ref state);
    let support_interface_status = SRC5Impl::supports_interface(@state, IACCESSCONTROL_ID);
    assert(support_interface_status == true, ERRORS::INVALID_STATUS);
}

#[test]
#[available_gas(2000000)]
fn test_has_role() {
    let mut state = setup();
    assert(!AccessControlImpl::has_role(@state, ROLE, AUTHORIZED()), ERRORS::NO_ROLE);
    InternalImpl::_grant_role(ref state, ROLE, AUTHORIZED());
    assert(AccessControlImpl::has_role(@state, ROLE, AUTHORIZED()), ERRORS::SHOULD_HAVE_ROLE);
}





#[test]
#[available_gas(2000000)]
fn test_grant_role() {
    let mut state = setup();
    AccessControlImpl::grant_role(ref state, ROLE, AUTHORIZED());
    assert_event_role_granted(ROLE, AUTHORIZED(), ADMIN());
    assert(AccessControlImpl::has_role(@state, ROLE, AUTHORIZED()), ERRORS::SHOULD_HAVE_ROLE);
}

fn assert_event_role_granted(role: felt252, account: ContractAddress, sender: ContractAddress) {
    let event = pop_log::<RoleGranted>(ZERO()).unwrap();
    assert(event.role == role, 'Invalid `role`');
    assert(event.account == account, 'Invalid `account`');
    assert(event.sender == sender, 'Invalid `sender`');
    assert_no_events_left(ZERO());
}

fn assert_event_role_admin_changed(
    role: felt252, previous_admin_role: felt252, new_admin_role: felt252
) {
    let event = pop_log::<RoleAdminChanged>(ZERO()).unwrap();
    assert(event.role == role, 'Invalid `role`');
    assert(event.previous_admin_role == previous_admin_role, 'Invalid `previous_admin_role`');
    assert(event.new_admin_role == new_admin_role, 'Invalid `new_admin_role`');
    assert_no_events_left(ZERO());
}