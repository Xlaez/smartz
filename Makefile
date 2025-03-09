deploy_edu:
	forge script script/Counter.s.sol --rpc-url https://open-campus-codex-sepolia.drpc.org --broadcast -- --env .env
deploy_base:
	forge script script/Counter.s.sol:CounterScript --rpc-url https://sepolia.base.org --private-key $PRIVATE_KEY  --broadcast
deploy_nexus:
	forge script script/Counter.s.sol:CounterScript --rpc-url https://rpc.nexus.xyz/http --private-key $PRIVATE_KEY --broadcast