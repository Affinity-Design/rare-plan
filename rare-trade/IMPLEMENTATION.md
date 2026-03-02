# Rare Trade - Technical Implementation

> Code structure and implementation details

---

## Project Structure

```
rare-trade/
├── apps/
│   ├── api/                    # Hono API server
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   │   ├── agents.ts
│   │   │   │   ├── strategies.ts
│   │   │   │   ├── trades.ts
│   │   │   │   └── leaderboard.ts
│   │   │   ├── middleware/
│   │   │   │   ├── auth.ts
│   │   │   │   └── rateLimit.ts
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   ├── telegram/               # Telegram bot
│   │   ├── src/
│   │   │   ├── commands/
│   │   │   │   ├── start.ts
│   │   │   │   ├── strategy.ts
│   │   │   │   ├── trade.ts
│   │   │   │   └── leaderboard.ts
│   │   │   └── index.ts
│   │   └── package.json
│   │
│   └── web/                    # Next.js dashboard
│       ├── src/
│       │   ├── app/
│       │   ├── components/
│       │   └── lib/
│       └── package.json
│
├── packages/
│   ├── agent/                  # Agent core
│   │   ├── src/
│   │   │   ├── orchestrator.ts  # LangGraph setup
│   │   │   ├── memory.ts        # MemGPT pattern
│   │   │   ├── strategies/      # Built-in strategies
│   │   │   └── executor.ts      # Trade execution
│   │   └── package.json
│   │
│   ├── blockchain/             # Chain interactions
│   │   ├── src/
│   │   │   ├── chains/
│   │   │   │   ├── base.ts
│   │   │   │   ├── ethereum.ts
│   │   │   │   └── solana.ts
│   │   │   ├── dex/
│   │   │   │   └── aggregator.ts
│   │   │   └── wallet.ts
│   │   └── package.json
│   │
│   ├── database/               # Supabase client
│   │   ├── src/
│   │   │   ├── schema.ts
│   │   │   └── client.ts
│   │   └── package.json
│   │
│   └── shared/                 # Shared types/utils
│       ├── src/
│       │   ├── types.ts
│       │   └── constants.ts
│       └── package.json
│
├── infra/
│   ├── docker/
│   ├── k8s/
│   └── terraform/
│
├── package.json
├── turbo.json
└── README.md
```

---

## Core Agent Implementation

### Agent Orchestrator (LangGraph)

```typescript
// packages/agent/src/orchestrator.ts
import { StateGraph, END } from "@langchain/langgraph";
import { BaseMessage, HumanMessage, AIMessage } from "@langchain/core/messages";

interface AgentState {
  messages: BaseMessage[];
  marketData: MarketData;
  strategy: Strategy;
  positions: Position[];
  actions: TradeAction[];
  reflection: string;
}

// Define nodes
const observeNode = async (state: AgentState) => {
  const marketData = await fetchMarketData(state.strategy.pairs);
  return { ...state, marketData };
};

const reasonNode = async (state: AgentState) => {
  const analysis = await analyzeMarket(state.marketData, state.strategy);
  const reasoning = await generateReasoning(state, analysis);
  
  return {
    ...state,
    messages: [...state.messages, new AIMessage(reasoning)],
  };
};

const decideNode = async (state: AgentState) => {
  const decision = await makeDecision(state);
  
  if (decision.action === "HOLD") {
    return { ...state, actions: [] };
  }
  
  return {
    ...state,
    actions: [decision],
  };
};

const actNode = async (state: AgentState) => {
  if (state.actions.length === 0) {
    return state;
  }
  
  const results = await Promise.all(
    state.actions.map(action => executeTrade(action))
  );
  
  return {
    ...state,
    positions: updatePositions(state.positions, results),
  };
};

const reflectNode = async (state: AgentState) => {
  const reflection = await generateReflection(state);
  
  // Store lessons learned in archival memory
  await storeInArchive(state.agentId, reflection);
  
  return { ...state, reflection };
};

// Build the graph
const workflow = new StateGraph<AgentState>({
  channels: {
    messages: { value: (x: BaseMessage[], y: BaseMessage[]) => x.concat(y) },
    marketData: { value: null },
    strategy: { value: null },
    positions: { value: null },
    actions: { value: null },
    reflection: { value: null },
  },
});

workflow
  .addNode("observe", observeNode)
  .addNode("reason", reasonNode)
  .addNode("decide", decideNode)
  .addNode("act", actNode)
  .addNode("reflect", reflectNode)
  .addEdge("observe", "reason")
  .addEdge("reason", "decide")
  .addConditionalEdges("decide", (state) => {
    return state.actions.length > 0 ? "act" : "reflect";
  })
  .addEdge("act", "reflect")
  .addEdge("reflect", END);

export const agentGraph = workflow.compile();
```

### Memory Manager (MemGPT Pattern)

```typescript
// packages/agent/src/memory.ts
import { OpenAI } from "openai";

interface CoreMemory {
  identity: string;
  strategy: Strategy;
  riskProfile: RiskLevel;
  activePositions: Position[];
  dailyPnL: number;
}

interface WorkingMemory {
  recentTrades: Trade[];
  marketContext: string;
  pendingActions: Action[];
}

interface ArchivalMemory {
  episodes: Episode[];
  facts: Fact[];
}

class AgentMemory {
  private openai: OpenAI;
  private core: CoreMemory;
  private working: WorkingMemory;
  private archival: ArchivalMemory;
  
  constructor(agentId: string) {
    this.openai = new OpenAI();
    this.loadMemory(agentId);
  }
  
  // Get context window content
  getContext(): string {
    const coreContext = this.formatCoreMemory();
    const workingContext = this.formatWorkingMemory();
    const relevantArchive = this.searchArchive(this.working.marketContext);
    
    return `
${coreContext}

RECENT ACTIVITY:
${workingContext}

RELEVANT HISTORY:
${relevantArchive}
    `.trim();
  }
  
  // Self-directed memory operations
  async editCoreMemory(updates: Partial<CoreMemory>) {
    this.core = { ...this.core, ...updates };
    await this.persistMemory();
  }
  
  async archiveEpisode(episode: Episode) {
    // Extract facts from episode
    const facts = await this.extractFacts(episode);
    
    // Store in archival memory
    this.archival.episodes.push(episode);
    this.archival.facts.push(...facts);
    
    // Clear from working memory
    this.working.recentTrades = this.working.recentTrades.slice(-10);
    
    await this.persistMemory();
  }
  
  async searchArchive(query: string): Promise<string> {
    // Vector search over archival memory
    const embedding = await this.openai.embeddings.create({
      model: "text-embedding-3-small",
      input: query,
    });
    
    const results = await vectorSearch(embedding.data[0].embedding, {
      agentId: this.agentId,
      limit: 5,
    });
    
    return results.map(r => r.content).join("\n\n");
  }
  
  private formatCoreMemory(): string {
    return `
AGENT IDENTITY:
${this.core.identity}

STRATEGY:
${JSON.stringify(this.core.strategy, null, 2)}

RISK PROFILE: ${this.core.riskProfile}
ACTIVE POSITIONS: ${this.core.activePositions.length}
TODAY'S P&L: ${this.core.dailyPnL > 0 ? '+' : ''}${this.core.dailyPnL.toFixed(2)}%
    `.trim();
  }
}
```

---

## Telegram Bot Implementation

```typescript
// apps/telegram/src/index.ts
import { Bot, GrammyError } from "grammy";
import { conversations, createConversation } from "@grammyjs/conversations";
import { hydrate } from "@grammyjs/hydrate";

const bot = new Bot(process.env.TELEGRAM_BOT_TOKEN!);

// Middleware
bot.use(hydrate());
bot.use(conversations);

// Commands
bot.command("start", async (ctx) => {
  const userId = ctx.from!.id.toString();
  
  // Check if user exists
  let user = await getUser(userId);
  
  if (!user) {
    user = await createUser({
      telegramId: userId,
      username: ctx.from!.username,
    });
  }
  
  await ctx.reply(`
🪙 Welcome to Rare Trade!

Your personal AI trading agent.

Agent ID: ${user.agentId}
Balance: ${user.balance} RARE

Commands:
/strategy - Configure trading
/launch - Start trading
/status - View performance
/leaderboard - Top traders

Deposit RARE to activate:
/deposit
  `);
});

bot.command("deposit", async (ctx) => {
  const userId = ctx.from!.id.toString();
  const user = await getUser(userId);
  
  // Generate deposit address
  const address = await getDepositAddress(userId);
  
  await ctx.reply(`
💰 Deposit RARE

Send RARE tokens to:
\`${address}\`

Minimum: 500 RARE
Recommended: 1,500 RARE (3 months)

⏳ Waiting for deposit...
Use /balance to check
  `, { parse_mode: "Markdown" });
});

bot.command("strategy", async (ctx) => {
  await ctx.conversation.enter("strategyConversation");
});

// Strategy conversation
async function strategyConversation(conversation: any, ctx: any) {
  // Step 1: Choose type
  await ctx.reply("Choose strategy type:", {
    reply_markup: {
      inline_keyboard: [
        [{ text: "🐢 Conservative", callback_data: "conservative" }],
        [{ text: "🦊 Moderate", callback_data: "moderate" }],
        [{ text: "🦅 Aggressive", callback_data: "aggressive" }],
        [{ text: "⚙️ Custom", callback_data: "custom" }],
      ],
    },
  });
  
  const typeResponse = await conversation.waitForCallbackQuery([
    "conservative", "moderate", "aggressive", "custom"
  ]);
  
  const strategyType = typeResponse.callbackQuery.data;
  
  // Step 2: Choose pairs
  await ctx.reply("Select trading pairs:", {
    reply_markup: {
      inline_keyboard: [
        [{ text: "BTC/USDC", callback_data: "btc" }],
        [{ text: "ETH/USDC", callback_data: "eth" }],
        [{ text: "RARE/USDC", callback_data: "rare" }],
        [{ text: "✅ Done", callback_data: "done" }],
      ],
    },
  });
  
  // Step 3: Confirm
  await ctx.reply(`
Strategy: ${strategyType}
Pairs: ${selectedPairs.join(", ")}

Confirm? (yes/no)
  `);
  
  const confirm = await conversation.waitFor(":text");
  
  if (confirm.msg.text.toLowerCase() === "yes") {
    await saveStrategy(userId, strategy);
    await ctx.reply("✅ Strategy saved! /launch to start.");
  }
}

// Start bot
bot.start();
```

---

## API Implementation

```typescript
// apps/api/src/index.ts
import { Hono } from "hono";
import { cors } from "hono/cors";
import { logger } from "hono/logger";
import { jwt } from "hono/jwt";

const app = new Hono();

// Middleware
app.use("*", logger());
app.use("*", cors());

// Health check
app.get("/", (c) => c.json({ status: "ok", version: "1.0.0" }));

// Protected routes
app.use("/api/*", jwt({ secret: process.env.JWT_SECRET! }));

// Agents
app.get("/api/agents", async (c) => {
  const userId = c.get("jwtPayload").userId;
  const agents = await getAgentsByUser(userId);
  return c.json({ agents });
});

app.post("/api/agents", async (c) => {
  const userId = c.get("jwtPayload").userId;
  const body = await c.req.json();
  
  const agent = await createAgent({
    userId,
    strategy: body.strategy,
    chain: body.chain || "base",
  });
  
  return c.json({ agent }, 201);
});

app.post("/api/agents/:id/launch", async (c) => {
  const agentId = c.req.param("id");
  
  // Check subscription
  const subscription = await checkSubscription(agentId);
  if (!subscription.active) {
    return c.json({ error: "Subscription inactive" }, 402);
  }
  
  // Launch agent
  await launchAgent(agentId);
  
  return c.json({ status: "launched" });
});

// Leaderboard
app.get("/api/leaderboard", async (c) => {
  const category = c.req.query("category") || "all";
  const leaderboard = await getLeaderboard(category);
  return c.json({ leaderboard });
});

// Copy trade
app.post("/api/copy/:agentId", async (c) => {
  const sourceAgentId = c.req.param("agentId");
  const userId = c.get("jwtPayload").userId;
  
  // Charge RARE
  const price = await getCopyPrice(sourceAgentId);
  await chargeRare(userId, price);
  
  // Clone strategy
  const newAgent = await cloneStrategy(userId, sourceAgentId);
  
  return c.json({ agent: newAgent });
});

export default app;
```

---

## Database Schema

```sql
-- Supabase schema

-- Users
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  telegram_id TEXT UNIQUE NOT NULL,
  wallet_address TEXT,
  balance DECIMAL(18, 8) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Agents
CREATE TABLE agents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  status TEXT DEFAULT 'inactive', -- inactive, active, paused
  is_private BOOLEAN DEFAULT false,
  strategy JSONB NOT NULL,
  chain TEXT DEFAULT 'base',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trades
CREATE TABLE trades (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id),
  pair TEXT NOT NULL,
  side TEXT NOT NULL, -- buy, sell
  amount DECIMAL(18, 8) NOT NULL,
  price DECIMAL(18, 8) NOT NULL,
  tx_hash TEXT,
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Positions
CREATE TABLE positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id UUID REFERENCES agents(id),
  pair TEXT NOT NULL,
  amount DECIMAL(18, 8) NOT NULL,
  entry_price DECIMAL(18, 8) NOT NULL,
  current_price DECIMAL(18, 8),
  pnl DECIMAL(18, 8),
  opened_at TIMESTAMPTZ DEFAULT NOW(),
  closed_at TIMESTAMPTZ
);

-- Subscriptions
CREATE TABLE subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  tier TEXT NOT NULL, -- basic, pro, whale
  rare_amount DECIMAL(18, 8) NOT NULL,
  started_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  active BOOLEAN DEFAULT true
);

-- Skills marketplace
CREATE TABLE skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES users(id),
  name TEXT NOT NULL,
  description TEXT,
  type TEXT NOT NULL, -- indicator, strategy, risk, utility
  code TEXT NOT NULL,
  price_one_time DECIMAL(18, 8),
  price_subscription DECIMAL(18, 8),
  downloads INTEGER DEFAULT 0,
  rating DECIMAL(3, 2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Leaderboard view
CREATE VIEW leaderboard AS
SELECT 
  a.id AS agent_id,
  u.telegram_id,
  a.name,
  a.is_private,
  COUNT(t.id) AS total_trades,
  SUM(CASE WHEN t.side = 'buy' AND p.pnl > 0 THEN 1 ELSE 0 END)::FLOAT / 
    NULLIF(COUNT(t.id), 0) * 100 AS win_rate,
  SUM(p.pnl) AS total_pnl,
  AVG(p.pnl) AS avg_pnl
FROM agents a
JOIN users u ON a.user_id = u.id
LEFT JOIN trades t ON t.agent_id = a.id
LEFT JOIN positions p ON p.agent_id = a.id
WHERE a.is_private = false
GROUP BY a.id, u.telegram_id, a.name, a.is_private
ORDER BY total_pnl DESC;
```

---

## Environment Setup

```bash
# .env.example

# API
API_PORT=3000
JWT_SECRET=your-secret-key

# Telegram
TELEGRAM_BOT_TOKEN=your-bot-token

# Database
DATABASE_URL=postgresql://...
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key

# Redis
REDIS_URL=redis://localhost:6379

# Blockchain
ALCHEMY_API_KEY=your-alchemy-key
COINBASE_CDP_API_KEY=your-cdp-key

# AI
ANTHROPIC_API_KEY=your-anthropic-key
OPENAI_API_KEY=your-openai-key

# Rare Token
RARE_TOKEN_ADDRESS=0x...
RARE_TREASURY_ADDRESS=0x...
```

---

*Implementation guide by Felix | Rare Coin*
