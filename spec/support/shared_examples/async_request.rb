RSpec.shared_examples 'async_request' do
  it 'returns status code accepted' do
    expect(response).to have_http_status(:accepted)
  end

  it 'returns the response id and url to retrive the data later' do
    expect(response_body.keys).to contain_exactly('response', 'job_id', 'url')
  end

  it 'enqueues a job' do
    expect(AsyncRequest::JobProcessor.jobs.size).to eq(1)
  end

  it 'creates the right job' do
    expect(AsyncRequest::Job.last.worker).to eq(worker_name)
  end

  it 'creates a job with given parameters' do
    expect(AsyncRequest::Job.last.params).to eq(parameters)
  end
end
