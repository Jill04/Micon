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

  describe("[Testcase 6: To create the micon who is not the owner ]", () => {
    it("Edition Exists", async () => {
      await micon.createMicon(1);
      try {
        await micon.createMicon(9,{from : accounts[4]});
      }
      catch{
      }
    });
  });

  describe("[Testcase 7: To sell an edition back]", () => {
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

  describe("[Testcase 8: To own editions of multiple micons]", () => {
    it("Buy Micon", async () => {
      await micon.createMicon(5);
      await micon.createMicon(4);
      await micon.buyEdition(2,2,{from : accounts[3]});
      await micon.buyEdition(1,4,{from:accounts[3]});
      var actual = await micon.editionOwner(2,2);
      var expected = accounts[3];
      assert.equal(actual,expected);
      var actual = await micon.editionOwner(1,4);
      var expected = accounts[3];
      assert.equal(actual,expected);
    });
  });

  describe("[Testcase 9: To determine previously owned edition owner]", () => {
    it("Sell Micon", async () => {
      await micon.createMicon(3);
      await micon.createMicon(8);
      await micon.buyEdition(2,6,{from : accounts[8]});
      await micon.setApprovalForAll(micon.address,true,{from:accounts[8]});
      await micon.sellEdition(2,6,{from:accounts[8]});
      var actual = await micon.previouslyOwnedEdition(2,6);
      var expected = accounts[8];
      assert.equal(actual,expected);
    });
  });

  describe("[Testcase 10: To try to sell the edition who is not an owner]", () => {
    it("Sell Micon", async () => {
      await micon.createMicon(10);
      await micon.createMicon(3);
      await micon.createMicon(7);
      await micon.buyEdition(3,7,{from : accounts[4]});
      await micon.buyEdition(1,4,{from : accounts[2]});
      await micon.setApprovalForAll(micon.address,true,{from:accounts[2]});
      try{
        await micon.sellEdition(1,5,{from:accounts[2]});
      }catch{
      }
    });
  });

  describe("[Testcase 11: To sell the edition without approval]", () => {
    it("Sell Micon", async () => {
      await micon.createMicon(10);
      await micon.createMicon(7);
      await micon.buyEdition(2,5,{from : accounts[5]});
      await micon.buyEdition(1,4,{from : accounts[2]});
      try{
        await micon.sellEdition(2,3,{from:accounts[5]});
      }catch{
      }
    });
  });

  describe("[Testcase 12: To determine whether the edition of micon exists or not]", () => {
    it("Edition Exists", async () => {
      await micon.createMicon(5);
      await micon.createMicon(1);
      var actual = await micon.editionExists(2);
      var expected = false;
      assert.equal(actual,expected);
    });
  });
});
