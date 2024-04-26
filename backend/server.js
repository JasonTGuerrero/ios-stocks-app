const express = require("express");
const cors = require("cors");
const path = require("path");
const axios = require("axios");
const { MongoClient } = require("mongodb");
const app = express();
app.use(cors());
app.use(express.json());
// app.use(express.static(path.join(__dirname, "dist", "frontend", "browser")));

// Replace the uri string with your connection string.
const uri =
	"mongodb+srv://jsnguerrero9:JTGwarrior1!@csci571mongodb.7q1qdbi.mongodb.net/?retryWrites=true&w=majority&appName=CSCI571mongodb";

const client = new MongoClient(uri);

app.get("/money/", async (req, res) => {
	try {
		// Find the document in the collection and return the money value
		await client.connect();
		const db = client.db("CSCI_571");
		const money = db.collection("money");
		const moneyData = await money.findOne();
		if (moneyData) {
			res.json({ money: moneyData.money });
		} else {
			res.status(404).json({ error: "Money data not found" });
		}
	} catch (error) {
		console.error("Error fetching money data:", error);
		res.status(500).json({ error: "Internal server error" });
	}
});

app.get("/stock_favorites/", async (req, res) => {
	try {
	    await client.connect();
	    const db = client.db("CSCI_571");
	    const favorites = db.collection("Stock Favorites");
	    const favoritesData = await favorites.find().toArray();
	    res.json({ favorites: favoritesData }); // Always return the favorites data
	} catch (error) {
	    console.error("Error fetching favorites data:", error);
	    res.status(500).json({ error: "Internal server error" });
	}
 });

async function run() {
	try {
		const stock_database = client.db("CSCI_571");
		const money = stock_database.collection("money");
		const money_value = await money.findOne();
		console.log(money_value);

		const favorites = stock_database.collection("Stock Favorites");
		const favorites_list = await favorites.find().toArray();
		console.log(favorites_list)
	} finally {
		// Ensures that the client will close when you finish/error
		await client.close();
	}
}
run().catch(console.dir);

app.get("/", (req, res) => {
	res.sendFile(
		path.join(__dirname, "dist", "frontend", "browser", "index.html")
	);
});

const PORT = process.env.PORT || 3000;
const FINNHUB_API_KEY = "cmvcf0pr01qog1iut58gcmvcf0pr01qog1iut590";
const POLYGON_API_KEY = "KChMpFN394POCVhUToyR7RAus7qdiSea";

// Endpoint to fetch company profile
app.get("/company-profile/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const apiUrl = `https://finnhub.io/api/v1/stock/profile2?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching company profile:", error);
		res.status(500).json({ error: "Failed to fetch company profile" });
	}
});

// Endpoint to fetch company quote from Finnhub
app.get("/company-quote/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const apiUrl = `https://finnhub.io/api/v1/quote?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching company quote:", error);
		res.status(500).json({ error: "Failed to fetch company quote" });
	}
});

// Endpoint to search for stock symbols on Finnhub
app.get("/stock-search/:symbol", async (req, res) => {
	try {
	    const symbol = req.params.symbol;
	    const apiUrl = `https://finnhub.io/api/v1/search?q=${symbol}&token=${FINNHUB_API_KEY}`;
	    const response = await axios.get(apiUrl);
	    
	    // Filter the results to include only "Common Stock" and symbols without '.'
	    const filteredResults = response.data.result.filter(result => {
		   return result.type === "Common Stock" && !result.symbol.includes(".");
	    });
 
	    // Update the response data with the filtered results
	    response.data.result = filteredResults;
 
	    res.json(response.data);
	} catch (error) {
	    console.error("Error searching for stock symbols:", error);
	    res.status(500).json({ error: "Failed to search for stock symbols" });
	}
 });
 

// Endpoint to fetch company news from Finnhub
app.get("/company-news/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const today = new Date();
		const fromDate = new Date(
			today.getFullYear(),
			today.getMonth(),
			today.getDate() - 7
		)
			.toISOString()
			.split("T")[0]; // 7 days ago
		const toDate = today.toISOString().split("T")[0]; // Today's date
		const apiUrl = `https://finnhub.io/api/v1/company-news?symbol=${symbol}&from=${fromDate}&to=${toDate}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching company news:", error);
		res.status(500).json({ error: "Failed to fetch company news" });
	}
});

// Endpoint to fetch company recommendation trends from Finnhub
app.get("/recommendation-trends/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const apiUrl = `https://finnhub.io/api/v1/stock/recommendation?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching recommendation trends:", error);
		res.status(500).json({
			error: "Failed to fetch recommendation trends",
		});
	}
});

// Endpoint to fetch insider sentiment from Finnhub
app.get("/insider-sentiment/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const fromDate = "2022-01-01"; // Default from date
		const apiUrl = `https://finnhub.io/api/v1/stock/insider-sentiment?symbol=${symbol}&from=${fromDate}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching insider sentiment:", error);
		res.status(500).json({ error: "Failed to fetch insider sentiment" });
	}
});

// Endpoint to fetch company peers from Finnhub
app.get("/company-peers/:symbol", async (req, res) => {
	try {
	    const symbol = req.params.symbol;
	    const apiUrl = `https://finnhub.io/api/v1/stock/peers?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
	    const response = await axios.get(apiUrl);
	    const symbols = response.data;
	    const filteredSymbols = symbols.filter(symbol => !symbol.includes('.'));
	    res.json(filteredSymbols);
	} catch (error) {
	    console.error("Error fetching company peers:", error);
	    res.status(500).json({ error: "Failed to fetch company peers" });
	}
 });
 

// TODO: set null values in the response object to 0
// Endpoint to fetch company earnings from Finnhub
app.get("/company-earnings/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		const apiUrl = `https://finnhub.io/api/v1/stock/earnings?symbol=${symbol}&token=${FINNHUB_API_KEY}`;
		const response = await axios.get(apiUrl);

		// Directly send the earnings data
		res.json(response.data);
	} catch (error) {
		console.error("Error fetching company earnings:", error);
		res.status(500).json({ error: "Failed to fetch company earnings" });
	}
});

app.get("/stock-hourly-chart/:symbol", async (req, res) => {
	try {
		const symbol = req.params.symbol;
		// Get the current date
		const currentDate = new Date();
		// Format the end date in YYYY-MM-DD format
		const formattedEndDate = formatDate(currentDate);
		// Get date from 1 day ago
		const oneDayAgo = new Date(
			currentDate.setDate(currentDate.getDate() - 3)
		);
		// Format the start date in YYYY-MM-DD format
		const formattedStartDate = formatDate(oneDayAgo);
		// Construct the API URL
		const apiUrl = `https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/hour/${formattedStartDate}/${formattedEndDate}?adjusted=true&sort=asc&apiKey=${POLYGON_API_KEY}`;
		// Fetch stock chart data from Polygon.io API
		const response = await axios.get(apiUrl);
		// Send the fetched data to the client
		res.json(response.data);
	} catch (error) {
		// Handle errors
		console.error("Error fetching stock chart data:", error);
		res.status(500).json({ error: "Failed to fetch stock chart data" });
	}
});

// Function to format date in YYYY-MM-DD format
function formatDate(date) {
	const year = date.getFullYear();
	const month = String(date.getMonth() + 1).padStart(2, "0");
	const day = String(date.getDate()).padStart(2, "0");
	return `${year}-${month}-${day}`;
}

// Endpoint to fetch stock chart data from Polygon.io
app.get("/stock-chart/:symbol", async (req, res) => {
	try {
	    const symbol = req.params.symbol;
	    const today = new Date();
	    const startDate = new Date(
		   today.getFullYear() - 2, // Subtract 2 years from the current year
		   today.getMonth(), // Use the current month
		   today.getDate() // Use the current day
	    )
		   .toISOString()
		   .split("T")[0];
	    const endDate = today.toISOString().split("T")[0];
	    const apiUrl = `https://api.polygon.io/v2/aggs/ticker/${symbol}/range/1/day/${startDate}/${endDate}?adjusted=true&sort=asc&apiKey=${POLYGON_API_KEY}`;
	    const response = await axios.get(apiUrl);
	    res.json(response.data);
	} catch (error) {
	    console.error("Error fetching stock chart data:", error);
	    res.status(500).json({ error: "Failed to fetch stock chart data" });
	}
 });
 

// Start the server
app.listen(PORT, () => {
	console.log(`Server is running on http://localhost:${PORT}`);
});
