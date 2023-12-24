#[starknet::contract]
mod SRC5 {
    use components::interface;

    #[storage]
    struct Storage {
        SRC5_supported_interfaces: LegacyMap<felt252, bool>
    }

    //////////////
    //ERROR
    /////////////
    mod Error{
        const INVALID_ID:felt252 = 'SRC5: invalid id';
    }

    #[external(v0)]
    impl SRC5Impl of interface::ISRC5<ContractState> {
        fn supports_interface(self: @ContractState, interface_id: felt252) -> bool {
            if interface_id == interface::ISRC_ID {
                return true;
            }
            return self.SRC5_supported_interfaces.read(interface_id);
        }
    }


    #[external(v0)]
    impl SRC5CamelImpl of interface::ISRC5Camel<ContractState> {
        fn supportsInterface(self: @ContractState, interface_id: felt252) -> bool {
            SRC5Impl::supports_interface(self, interface_id)
        }
    }

    #[generate_trait]
    impl InternalImpl of InternalTrait {
        fn register_interface(ref self: ContractState, interface_id: felt252) {
            self.SRC5_supported_interfaces.write(interface_id, true)
        }
        fn deregister_interface(ref self: ContractState, interface_id: felt252) {
            assert(interface_id != interface::ISRC_ID, Error::INVALID_ID);
            self.SRC5_supported_interfaces.write(interface_id, false)
        }
    }
}

