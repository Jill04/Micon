const {
  BN, // Big Number support
  constants, // Common constants, like the zero address and largest integers
  expectEvent, // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require("@openzeppelin/test-helpers");

const truffleAssert = require("truffle-assertions");
const { assert, expect } = require("chai");
const Micon = artifacts.require("Micon");


require("chai").use(require("chai-bignumber")(BN)).should();


contract("Micon", () => {
  it("Should deploy smart contract properly", async () => {
    const micon = await Micon.deployed();
   
    assert(micon.address !== "");
  });
  beforeEach(async function () {
    micon = await Micon.new();
    accounts = await web3.eth.getAccounts();
  });

  describe("[Testcase 1: To create micon]", () => {
    it("Create Micon", async () => {
      await micon.createMicon(5);
    });
  });

  describe("[Testcase 2: To buy an edition of the micon]", () => {
    it("Buy Micon", async () => {
      await micon.createMicon(3);
      await micon.buyEdition(1,2,{from : accounts[4]});
      var actual = await micon.editionOwner(1,2);
      var expected = accounts[4];
      assert.equal(actual,expected);
    });
  });
  
  describe("[Testcase 3: To create more than 10 editions of micon ]", () => {
    it("Create Micon", async () => {
      await micon.createMicon(7);
      try{
        await micon.createMicon(12);
      }
      catch{
      }
    });
  });
  describe("[Testcase 4: To create micon with no editions]", () => {
    it("Create Micon", async () => {
      await micon.createMicon(1);
      await micon.buyEdition(1,0,{from : accounts[2]});
    });
  });

  describe("[Testcase 5: To buy an edition of the same micon again]", () => {
    it("Buy Micon", async () => {
      await micon.createMicon(3);
      await micon.buyEdition(1,2);
      try{
          await micon.buyEdition(1,3,{from : accounts[4]});
      }catch{
      }
    });
  });

  
  describe("[Testcase 6: To sell an edition back]", () => {
    it("Sell Micon", async () => {
      await micon.createMicon(5);
      await micon.createMicon(4);
      await micon.buyEdition(2,2,{from : accounts[6]});
      await micon.setApprovalForAll(micon.address,true,{from:accounts[6]});
      await micon.sellEdition(2,2,{from:accounts[6]});
      var actual = await micon.editionOwner(2,2);
      var expected = micon.address;
      assert.equal(actual,expected);
    });
  });
});
