/**
 * Calculate the total balance for a restaurant based on its transactions
 * 
 * Balance formula: sum of (jarsSold - jarsReturned) for all transactions
 * This represents the total number of empty boxes (علب فارغة) that the restaurant owes
 * 
 * @param {Array} transactions - Array of transaction objects with jarsSold and jarsReturned
 * @returns {Number} - Total number of empty boxes owed by the restaurant
 */
const calculateBalance = (transactions) => {
  if (!transactions || !Array.isArray(transactions)) {
    return 0;
  }

  return transactions.reduce((totalBalance, transaction) => {
    const netJars = transaction.jarsSold - transaction.jarsReturned;
    return totalBalance + netJars;
  }, 0);
};

module.exports = {
  calculateBalance,
};
