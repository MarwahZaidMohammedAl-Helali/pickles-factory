/**
 * Calculate the total balance for a restaurant based on its transactions
 * 
 * Balance formula: sum of (jarsSold - jarsReturned) × productPrice for each transaction
 * 
 * @param {Array} transactions - Array of transaction objects with jarsSold, jarsReturned, and product price
 * @returns {Number} - Total balance owed by the restaurant
 */
const calculateBalance = (transactions) => {
  if (!transactions || !Array.isArray(transactions)) {
    return 0;
  }

  return transactions.reduce((totalBalance, transaction) => {
    const netJars = transaction.jarsSold - transaction.jarsReturned;
    const productPrice = transaction.productPrice || 0;
    const transactionAmount = netJars * productPrice;
    
    return totalBalance + transactionAmount;
  }, 0);
};

module.exports = {
  calculateBalance,
};
