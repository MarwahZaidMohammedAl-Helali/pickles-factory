/**
 * Calculate the total balance for a restaurant based on its transactions
 * 
 * Balance formula: sum of jarsReturned for all transactions
 * This represents the total number of empty boxes (علب فارغة) returned by the restaurant
 * 
 * @param {Array} transactions - Array of transaction objects with jarsSold and jarsReturned
 * @returns {Number} - Total number of empty boxes returned by the restaurant
 */
const calculateBalance = (transactions) => {
  if (!transactions || !Array.isArray(transactions)) {
    return 0;
  }

  return transactions.reduce((totalBalance, transaction) => {
    return totalBalance + transaction.jarsReturned;
  }, 0);
};

module.exports = {
  calculateBalance,
};
