import chai from 'chai';
import chaiHttp from 'chai-http';
import { expect } from 'chai';

chai.use(chaiHttp);

// Minimal smoke test - requires dev server running via `npm run dev`
describe('GET /', () => {
  it('returns 200 and message', async () => {
    const res = await chai.request('http://localhost:3000').get('/');
    expect(res).to.have.status(200);
    expect(res.body.message).to.equal('Hello from Node app');
  });
});
