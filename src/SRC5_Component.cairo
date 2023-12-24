#[starknet::component]
mod SRC5{
    use components::interface;

    #[storage]
    struct Storage{
        SRC5_supported_interface: LegacyMap<felt252,bool>
    }

    mod Error {
        const INVALID_ID:felt252 = 'SRC5: invalid id';
    }

   #[embeddable_as(SRC5Impl)]
    impl SRC5<
        TContractState, +HasComponent<TContractState>
    > of interface::ISRC5<ComponentState<TContractState>> {
        /// Returns whether the contract implements the given interface.
        fn supports_interface(
            self: @ComponentState<TContractState>, interface_id: felt252
        ) -> bool {
            if interface_id == interface::ISRC_ID {
                return true;
            }
            self.SRC5_supported_interface.read(interface_id)
        }
    }

    #[embeddable_as(SRC5CamelImpl)]
    impl SRC5Camel<TContractState, +HasComponent<TContractState>> of interface::ISRC5Camel<ComponentState<TContractState>>{
        fn supportsInterface(self: @ComponentState<TContractState>, interface_id:felt252) -> bool{
            SRC5::supports_interface(self,interface_id)
        }
    }

    #[generate_trait]
    impl InternalImpl<TContractState, +HasComponent<TContractState>> of InternalTrait<TContractState> {
        fn register_interface(ref self:ComponentState<TContractState>, interface_id:felt252){
            self.SRC5_supported_interface.write(interface_id, true);
        }

    fn deregister_interface(ref self:ComponentState<TContractState>, interface_id:felt252){
        assert(interface_id != interface::ISRC_ID, Error::INVALID_ID);
        self.SRC5_supported_interface.write(interface_id,false);
    }
    }

}