// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SkillTokenization {
    struct Skill {
        uint256 id;
        string name;
        string description;
        address owner;
        uint256 price;
        bool isAvailable;
    }

    uint256 public nextSkillId;
    mapping(uint256 => Skill) public skills;
    mapping(address => uint256[]) public ownerSkills;

    event SkillCreated(uint256 id, string name, address owner, uint256 price);
    event SkillPurchased(uint256 id, address newOwner);
    event SkillUpdated(uint256 id, string name, string description, uint256 price, bool isAvailable);

    function createSkill(string memory name, string memory description, uint256 price) public {
        require(bytes(name).length > 0, "Skill name cannot be empty");
        require(bytes(description).length > 0, "Skill description cannot be empty");
        require(price > 0, "Skill price must be greater than zero");

        skills[nextSkillId] = Skill(nextSkillId, name, description, msg.sender, price, true);
        ownerSkills[msg.sender].push(nextSkillId);

        emit SkillCreated(nextSkillId, name, msg.sender, price);
        nextSkillId++;
    }

    function purchaseSkill(uint256 skillId) public payable {
        Skill storage skill = skills[skillId];
        require(skill.isAvailable, "Skill is not available for purchase");
        require(msg.value == skill.price, "Incorrect price sent");
        require(skill.owner != msg.sender, "Cannot purchase your own skill");

        payable(skill.owner).transfer(msg.value);

        // Transfer ownership
        skill.owner = msg.sender;
        skill.isAvailable = false;

        emit SkillPurchased(skillId, msg.sender);
    }

    function updateSkill(uint256 skillId, string memory name, string memory description, uint256 price, bool isAvailable) public {
        Skill storage skill = skills[skillId];
        require(skill.owner == msg.sender, "Only the owner can update the skill");

        skill.name = name;
        skill.description = description;
        skill.price = price;
        skill.isAvailable = isAvailable;

        emit SkillUpdated(skillId, name, description, price, isAvailable);
    }

    function getSkillsByOwner(address owner) public view returns (uint256[] memory) {
        return ownerSkills[owner];
    }

    function getSkill(uint256 skillId) public view returns (Skill memory) {
        return skills[skillId];
    }
}
