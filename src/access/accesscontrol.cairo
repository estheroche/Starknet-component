#[starknet::contract]
mod AccessControl {
    use core::starknet::event::EventEmitter;
    use components::access::interface;
    use starknet::ContractAddress;
    use starknet::get_caller_address;
    use components::SRC5_Component::SRC5 as src5_component;

    component!(path: src5_component, storage: src5, event: SRC5Event);

    #[abi(embed_v0)]
    impl SRC5Impl = src5_component::SRC5Impl<ContractState>;
    impl SRC5InternalImpl = src5_component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
        AccessControl_role_admin: LegacyMap<felt252, felt252>,
        AccessControl_role_member: LegacyMap<(felt252, ContractAddress), bool>,
        #[substorage(v0)]
        src5: src5_component::Storage
    }

    /////////////
    ////ERROR
    ////////

    mod Errors {
        const INVALID_CALLER: felt252 = 'Can only renounce role for self';
        const MISSING_ROLE: felt252 = 'Caller is missing role';
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RoleGranted: RoleGranted,
        RoleRevoked: RoleRevoked,
        RoleAdminChanged: RoleAdminChanged,
        SRC5Event: src5_component::Event
    }

    // ////////EVENTS
    #[derive(Drop, starknet::Event)]
    struct RoleGranted {
        role: felt252,
        account: ContractAddress,
        sender: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct RoleRevoked {
        role: felt252,
        account: ContractAddress,
        sender: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct RoleAdminChanged {
        role: felt252,
        previous_admin_role: felt252,
        new_admin_role: felt252
    }

    #[external(v0)]
    impl AccessControlImpl of interface::IAccessControl<ContractState> {
        fn has_role(self: @ContractState, role: felt252, account: ContractAddress) -> bool {
            self.AccessControl_role_member.read((role, account))
        }

        fn get_role_admin(self: @ContractState, role: felt252) -> felt252 {
            self.AccessControl_role_admin.read(role)
        }

        fn grant_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            let admin = AccessControlImpl::get_role_admin(@self, role);
            self.assert_only_role(admin);
            self._grant_role(role, account);
        }

        fn revoke_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            let admin = AccessControlImpl::get_role_admin(@self, role);
            self.assert_only_role(admin);
            self._revoke_role(role, account);
        }

        fn renounce_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            let caller: ContractAddress = get_caller_address();
            assert(caller == account, Errors::INVALID_CALLER);
            self._revoke_role(role, account);
        }
    }


    #[generate_trait]
    impl InternalImpl of InternalTrait {
        //  register accesscontrol_ID
        fn initializer(ref self: ContractState) {
            self.src5.register_interface(interface::IACCESSCONTROL_ID);
        }

        fn assert_only_role(self: @ContractState, role: felt252) {
            let caller: ContractAddress = get_caller_address();
            let authorized: bool = AccessControlImpl::has_role(self, role, caller);
            assert(authorized, Errors::MISSING_ROLE);
        }

        fn _grant_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            if !AccessControlImpl::has_role(@self, role, account) {
                let caller: ContractAddress = get_caller_address();
                self.AccessControl_role_member.write((role, account), true);
                self.emit(RoleGranted { role, account, sender: caller });
            }
        }

        fn _revoke_role(ref self: ContractState, role: felt252, account: ContractAddress) {
            if !AccessControlImpl::has_role(@self, role, account) {
                let caller = get_caller_address();
                self.AccessControl_role_member.write((role, account), true);
                self.emit(RoleRevoked { role, account, sender: caller });
            }
        }

        fn _set_role_admin(ref self: ContractState, role: felt252, admin_role: felt252) {
            let previous_admin_role = AccessControlImpl::get_role_admin(@self, role);
            self.AccessControl_role_admin.write(role, previous_admin_role);
            self.emit(RoleAdminChanged { role, previous_admin_role, new_admin_role: admin_role });
        }
    }
}

