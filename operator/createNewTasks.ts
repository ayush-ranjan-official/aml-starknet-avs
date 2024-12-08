import { ethers } from "ethers";
import * as dotenv from "dotenv";
import { Groq } from 'groq-sdk';
import { type ChatCompletionMessageParam, type ChatCompletionTool } from 'groq-sdk/resources/chat/completions';
const fs = require('fs');
const path = require('path');
dotenv.config();

// Setup env variables
const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);
const wallet = new ethers.Wallet(process.env.PRIVATE_KEY!, provider);
/// TODO: Hack
let chainId = 31337;

const avsDeploymentData = JSON.parse(fs.readFileSync(path.resolve(__dirname, `../contracts/deployments/hello-world/${chainId}.json`), 'utf8'));
const helloWorldServiceManagerAddress = avsDeploymentData.addresses.helloWorldServiceManager;
const helloWorldServiceManagerABI = JSON.parse(fs.readFileSync(path.resolve(__dirname, '../abis/HelloWorldServiceManager.json'), 'utf8'));
// Initialize contract objects from ABIs
const helloWorldServiceManager = new ethers.Contract(helloWorldServiceManagerAddress, helloWorldServiceManagerABI, wallet);

//const apiKeyGroq = process.env.GROQ_API_KEY;
const apiKeyGroq = process.env.GROQ_API_KEY;

const client = new Groq({ apiKey: apiKeyGroq, dangerouslyAllowBrowser: true });
const MODEL = 'llama3-8b-8192';

async function runConversation(prompt: string): Promise<string> {
    const messages: ChatCompletionMessageParam[] = [
        {
            role: "system",
            content: "You are a smart assistant for a DeFi protocol, tasked with analyzing transactions to detect suspicious activity based on the following rules: (1) High-Volume Swaps: Transactions exceeding certain token amounts, (2) Frequent Trades by Single Address: Unusually high number of trades by one address, (3) Large Liquidity Movements: Significant deposits or withdrawals, (4) Unusual Fee Accumulations: Sudden spikes in fee collections, (5) Suspicious Position Updates: Large or rapid changes in liquidity or fees, (6) Unauthorized Access Attempts: Calls to restricted functions by non-admins, (7) Protocol Fee Withdrawals: Tracking large or frequent fee withdrawals; if no issues are found, return that the transaction is valid. Input Transaction Format: { 'event': '<event_type>', 'locker': '<address>', 'pool_key': { 'token0': '<address>', 'token1': '<address>', 'fee': '<value>', 'tick_spacing': '<value>', 'extension': '<address>' }, 'params': { 'amount': { 'mag': '<value>', 'sign': '<True/False>' }, 'is_token1': '<True/False>', 'sqrt_ratio_limit': { 'low': '<value>', 'high': '<value>' }, 'skip_ahead': '<value>' }, 'delta': { 'amount0': { 'mag': '<value>', 'sign': '<True/False>' }, 'amount1': { 'mag': '<value>', 'sign': '<True/False>' } }, 'sqrt_ratio_after': { 'low': '<value>', 'high': '<value>' }, 'tick_after': { 'mag': '<value>', 'sign': '<True/False>' }, 'liquidity_after': '<value>', 'timestamp': '<timestamp>', 'txHash': '<transaction_hash>', 'blockNumber': '<block_number>' }; Output Format: If flagged, return JSON { 'txHash': '<transaction_hash>', 'issue': '<detected_issue>', 'details': { 'amount0': '<value>', 'amount1': '<value>', 'timestamp': '<timestamp>' }, 'blockNumber': '<block_number>' }; Example Input: { 'event': 'Swapped', 'locker': '0xLockerAddress', 'pool_key': { 'token0': '0xToken0Address', 'token1': '0xToken1Address', 'fee': '3000', 'tick_spacing': '60', 'extension': '0xExtensionAddress' }, 'params': { 'amount': { 'mag': '1000', 'sign': 'False' }, 'is_token1': 'True', 'sqrt_ratio_limit': { 'low': '123456789', 'high': '987654321' }, 'skip_ahead': '0' }, 'delta': { 'amount0': { 'mag': '500', 'sign': 'False' }, 'amount1': { 'mag': '500', 'sign': 'True' } }, 'sqrt_ratio_after': { 'low': '2233445566', 'high': '6655443322' }, 'tick_after': { 'mag': '120', 'sign': 'False' }, 'liquidity_after': '1000000', 'timestamp': '2024-04-25T12:10:00Z', 'txHash': '0xtxhashEKUBO123...', 'blockNumber': 123459 }; Output: { 'txHash': '0xtxhashEKUBO123...', 'issue': 'High-Volume Swap', 'details': { 'amount0': '500', 'amount1': '500', 'timestamp': '2024-04-25T12:10:00Z' }, 'blockNumber': 123459 };Task: Analyze the following transaction (provided in the prompt) and determine if it should be flagged, returning the JSON output as shown in the example."
        },
        {
            role: "user",
            content: prompt,
        }
    ];

    const response = await client.chat.completions.create({
        model: MODEL,
        messages: messages,
        stream: false,
        tool_choice: "auto",
        max_tokens: 4096
    });
    const responseMessage = response.choices[0].message;
    return responseMessage.content ?? '';
}


// Function to generate random names
async function generateRandomName(): Promise<string> {
    // const adjectives = ['Quick', 'Lazy', 'Sleepy', 'Noisy', 'Hungry'];
    // const nouns = ['Fox', 'Dog', 'Cat', 'Mouse', 'Bear'];
    // const adjective = adjectives[Math.floor(Math.random() * adjectives.length)];
    // const noun = nouns[Math.floor(Math.random() * nouns.length)];
    // const randomName = `${adjective}${noun}${Math.floor(Math.random() * 1000)}`;
    // return randomName;
    const jsonObject = {
      "event": "LiquidityAdded",
      "locker": "0xLockerAnotherAddress",
      "pool_key": {
        "token0": "0xTokenAAddress",
        "token1": "0xTokenBAddress",
        "fee": "500",
        "tick_spacing": "10",
        "extension": "0xAnotherExtensionAddress"
      },
      "params": {
        "amount": {
          "mag": "150000",
          "sign": "True"
        },
        "is_token1": "False",
        "sqrt_ratio_limit": {
          "low": "123123123",
          "high": "321321321"
        },
        "skip_ahead": "0"
      },
      "delta": {
        "amount0": {
          "mag": "70000",
          "sign": "True"
        },
        "amount1": {
          "mag": "80000",
          "sign": "True"
        }
      },
      "sqrt_ratio_after": {
        "low": "4455667788",
        "high": "8877665544"
      },
      "tick_after": {
        "mag": "250",
        "sign": "False"
      },
      "liquidity_after": "5000000",
      "timestamp": "2024-05-10T15:45:00Z",
      "txHash": "0xtxhashEXAMPLE456...",
      "blockNumber": 123987
    };
    
    
    // Convert JSON object to string
    const jsonString = JSON.stringify(jsonObject);
    
    //console.log(jsonString);
    
    let message = await runConversation(jsonString);
    // await runConversation('a')
    //   .then((value: string) => {
    //     message = value;
    //   })
    //   .catch((error: string) => {
    //     console.error("Promise rejected with error: " + error);
    //   });

      return message;
    
  }

async function createNewTask(taskName: string) {
  try {
    // Send a transaction to the createNewTask function
    const tx = await helloWorldServiceManager.createNewTask(taskName);
    
    // Wait for the transaction to be mined
    const receipt = await tx.wait();
    
    console.log(`Transaction successful with hash: ${receipt.hash}`);
  } catch (error) {
    console.error('Error sending transaction:', error);
  }
}

// Function to create a new task with a random name every 15 seconds
function startCreatingTasks() {
  let randomName = '';
  setInterval(async () => {
        await generateRandomName()
      .then((value: string) => {
        randomName = value;
      })
      .catch((error: string) => {
        console.error("Promise rejected with error: " + error);
      });
    //const randomName = generateRandomName();
    console.log(`Creating new task with name: ${randomName}`);
    createNewTask(randomName);
  }, 25000);
}

// Start the process
startCreatingTasks();
